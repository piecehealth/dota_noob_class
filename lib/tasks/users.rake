# frozen_string_literal: true

namespace :users do
  desc "Export users to CSV (provide FILE=path/to/users.csv)"
  task export: :environment do
    file_path = ENV["FILE"] || "tmp/users_export_#{Date.current}.csv"

    File.open(file_path, "w") do |f|
      # 写入表头
      f.puts "display_name,username,role,dota2_player_id,classroom_number,group_number,is_admin,password"

      User.find_each do |user|
        # CSV 转义处理
        display_name = escape_csv(user.display_name)
        username = escape_csv(user.username)
        role = user.role
        dota_id = user.dota2_player_id || ""
        classroom_num = user.classroom&.number || ""
        group_num = user.group&.number || ""
        is_admin = user.is_admin
        password = ""  # 密码不导出

        f.puts [display_name, username, role, dota_id, classroom_num, group_num, is_admin, password].join(",")
      end
    end

    puts "Exported #{User.count} users to #{file_path}"
  end

  desc "Import users from CSV (provide FILE=path/to/users.csv)"
  task import: :environment do
    file_path = ENV["FILE"]
    raise "Please provide FILE=path/to/users.csv" unless file_path

    lines = File.readlines(file_path, chomp: true)
    headers = lines.shift  # 移除表头

    created = 0
    updated = 0
    errors = []

    lines.each do |line|
      # 解析 CSV 行
      row = parse_csv_line(line)

      begin
        # 查找或创建班级
        classroom = nil
        if row["classroom_number"].present?
          classroom = Classroom.find_or_create_by!(number: row["classroom_number"]) do |c|
            c.name = "#{row["classroom_number"]}班"
          end
        end

        # 查找或创建小组
        group = nil
        if classroom && row["group_number"].present?
          group = Group.find_or_create_by!(classroom: classroom, number: row["group_number"])
        end

        # 查找或初始化用户（按 username 查找）
        user = User.find_or_initialize_by(username: row["username"])

        # 设置属性
        user.assign_attributes(
          display_name: row["display_name"],
          role: row["role"] || "student",
          dota2_player_id: row["dota2_player_id"].presence,
          classroom: classroom,
          group: group,
          is_admin: row["is_admin"] == "true",
          activation_token: SecureRandom.hex(16)
        )

        # 新用户设置密码
        if user.new_record?
          password = row["password"].presence || SecureRandom.hex(16)
          user.password = password
        end

        user.save!

        if user.previously_new_record?
          created += 1
        else
          updated += 1
        end
      rescue => e
        errors << { row: row["display_name"], error: e.message }
        Rails.logger.error "Failed to import user #{row['display_name']}: #{e.message}"
      end
    end

    puts "Import completed:"
    puts "  Created: #{created}"
    puts "  Updated: #{updated}"
    puts "  Errors: #{errors.count}"
    errors.each { |e| puts "    - #{e[:row]}: #{e[:error]}" }
  end

  # CSV 转义辅助方法
  def escape_csv(value)
    return "" if value.nil?
    str = value.to_s
    if str.include?(",") || str.include?('"') || str.include?("\n")
      str = str.gsub('"', '""')
      "\"#{str}\""
    else
      str
    end
  end

  # 简单的 CSV 行解析
  def parse_csv_line(line)
    result = {}
    fields = []
    current = +""
    in_quotes = false

    line.each_char do |char|
      if char == '"'
        if in_quotes
          current << char
        else
          in_quotes = true
        end
      elsif char == "," && !in_quotes
        fields << current
        current = +""
      else
        current << char
      end
    end
    fields << current

    headers = ["display_name", "username", "role", "dota2_player_id",
               "classroom_number", "group_number", "is_admin", "password"]
    headers.each_with_index do |h, i|
      result[h] = fields[i]&.strip || ""
    end
    result
  end
end

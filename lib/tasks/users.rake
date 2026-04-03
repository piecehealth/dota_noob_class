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

    created = 0
    updated = 0
    skipped = 0
    errors = []
    
    # 缓存已创建的班级和小组，避免重复查询
    classrooms_cache = {}
    groups_cache = {}
    usernames_cache = {}

    lines = File.readlines(file_path, chomp: true)
    header_line = lines.shift  # 移除表头
    total = lines.size

    lines.each_with_index do |line, index|
      # 简单解析CSV行
      fields = line.split(",", -1)  # -1 保留空字段
      
      # 确保至少有3个字段
      while fields.length < 3
        fields << ""
      end
      
      display_name = fields[0]&.strip
      class_group = fields[1]&.strip
      dota_player_id = fields[2]&.strip

      # 跳过空行
      if display_name.blank?
        skipped += 1
        next
      end
      
      # 每50条显示进度
      if (index + 1) % 50 == 0
        puts "Progress: #{index + 1}/#{total} (Created: #{created}, Updated: #{updated}, Errors: #{errors.count})"
      end

      begin
        # 解析班级和组（格式：X班Y组）
        classroom_number = nil
        group_number = nil
        
        if class_group.present?
          # 匹配格式如 "17班4组"
          if match = class_group.match(/(\d+)班(\d+)组/)
            classroom_number = match[1].to_i
            group_number = match[2].to_i
          end
        end

        # 查找或创建班级（使用缓存）
        classroom = nil
        if classroom_number.present?
          cache_key = classroom_number
          classroom = classrooms_cache[cache_key]
          unless classroom
            classroom = Classroom.find_or_create_by!(number: classroom_number) do |c|
              c.name = "#{classroom_number}班"
            end
            classrooms_cache[cache_key] = classroom
          end
        end

        # 查找或创建小组（使用缓存）
        group = nil
        if classroom && group_number.present?
          cache_key = "#{classroom.id}_#{group_number}"
          group = groups_cache[cache_key]
          unless group
            group = Group.find_or_create_by!(classroom: classroom, number: group_number)
            groups_cache[cache_key] = group
          end
        end

        # 生成username（用于登录）
        username = display_name.downcase.gsub(/[^a-z0-9]/, "_").squeeze("_")
        username = "student" if username.blank?
        
        # 确保username唯一（使用缓存 + 数据库检查）
        base_username = username
        counter = 1
        original_username = username
        while (usernames_cache[username] || User.exists?(username: username)) && usernames_cache[username] != display_name
          username = "#{base_username}_#{counter}"
          counter += 1
          # 防止无限循环
          if counter > 1000
            username = "#{base_username}_#{SecureRandom.hex(4)}"
            break
          end
        end
        usernames_cache[username] = display_name

        # 查找或初始化用户
        user = User.find_or_initialize_by(display_name: display_name)

        # 设置属性
        user.assign_attributes(
          username: username,
          role: "student",
          dota2_player_id: dota_player_id.presence,
          classroom: classroom,
          group: group,
          is_admin: false,
          activation_token: SecureRandom.hex(16)
        )

        # 新用户设置密码
        if user.new_record?
          password = SecureRandom.hex(16)
          user.password = password
        end

        user.save!

        if user.previously_new_record?
          created += 1
        else
          updated += 1
        end
      rescue => e
        errors << { row: display_name, error: e.message }
        puts "ERROR: #{display_name} - #{e.message}"
      end
    end

    puts "\nImport completed:"
    puts "  Total lines: #{total}"
    puts "  Created: #{created}"
    puts "  Updated: #{updated}"
    puts "  Skipped (empty): #{skipped}"
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

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../config/environment"

file_path = Rails.root.join("docs", "students.csv")
lines = File.readlines(file_path, chomp: true)
header = lines.shift

created = 0
errors = []

# 预加载所有班级和组
classrooms_cache = {}
groups_cache = {}
existing_users = Set.new

# 收集所有班级和组信息
classroom_groups = {}
lines.each do |line|
  fields = line.split(",", -1)
  next if fields.length < 2
  
  class_group = fields[1]&.strip
  if class_group && match = class_group.match(/(\d+)班(\d+)组/)
    classroom_number = match[1].to_i
    group_number = match[2].to_i
    classroom_groups[classroom_number] ||= Set.new
    classroom_groups[classroom_number] << group_number
  end
end

# 批量创建班级
puts "Creating classrooms..."
classroom_groups.keys.each do |num|
  classroom = Classroom.find_or_create_by!(number: num) do |c|
    c.name = "#{num}班"
  end
  classrooms_cache[num] = classroom
end

# 批量创建组
puts "Creating groups..."
classroom_groups.each do |class_num, groups|
  classroom = classrooms_cache[class_num]
  groups.each do |group_num|
    group = Group.find_or_create_by!(classroom: classroom, number: group_num)
    groups_cache["#{classroom.id}_#{group_num}"] = group
  end
end

puts "Importing users..."
lines.each_with_index do |line, index|
  fields = line.split(",", -1)
  next if fields.length < 2
  
  display_name = fields[0]&.strip
  class_group = fields[1]&.strip
  dota_player_id = fields[2]&.strip
  
  next if display_name.blank?
  
  puts "Progress: #{index + 1}/#{lines.size}" if (index + 1) % 100 == 0
  
  begin
    match = class_group&.match(/(\d+)班(\d+)组/)
    next unless match
    
    classroom_number = match[1].to_i
    group_number = match[2].to_i
    
    classroom = classrooms_cache[classroom_number]
    group = groups_cache["#{classroom.id}_#{group_number}"]
    
    # 检查是否已存在
    user_key = "#{classroom_number}_#{group_number}_#{display_name}"
    if existing_users.include?(user_key)
      next
    end
    existing_users << user_key
    
    # 生成 username
    safe_name = display_name.downcase.gsub(/[^a-z0-9]/, "_").squeeze("_").presence || "user"
    username = "#{classroom_number}_#{group_number}_#{safe_name}"
    
    # 确保唯一
    base_username = username
    counter = 1
    while User.exists?(username: username)
      username = "#{base_username}_#{counter}"
      counter += 1
    end
    
    # 创建用户（跳过验证加快导入）
    User.create!(
      username: username,
      display_name: display_name,
      role: "student",
      dota2_player_id: dota_player_id.presence,
      classroom: classroom,
      group: group,
      is_admin: false,
      password: SecureRandom.hex(16),
      activation_token: SecureRandom.hex(16)
    )
    
    created += 1
    
  rescue => e
    errors << { line: index + 2, name: display_name, error: e.message }
  end
end

puts "\n=== Import Summary ==="
puts "Total lines: #{lines.size}"
puts "Created: #{created}"
puts "Errors: #{errors.size}"

if errors.any?
  puts "\nErrors:"
  errors.first(20).each { |e| puts "  Line #{e[:line]} (#{e[:name]}): #{e[:error]}" }
end

puts "\nFinal counts:"
puts "  Users: #{User.count}"
puts "  Classrooms: #{Classroom.count}"
puts "  Groups: #{Group.count}"

require_relative "../config/environment.rb"
require 'pry'
class Student
  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
        SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
        SQL
    id = <<-SQL
      SELECT MAX(id) FROM students
      SQL
    if DB[:conn].execute("SELECT * FROM students WHERE id = ?", self.id).empty?
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute(id)[0][0]
    else
      self.update
    end

  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    new_student = self.new(row[0], row[1], row[2])
  end

  def self.find_by_name(student_name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
        SQL
    new_student = DB[:conn].execute(sql, student_name)

    new_student.map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    updated_student = Student.find_by_name(self.name)
    sql = <<-SQL
      UPDATE students SET name = ? WHERE id = ?
        SQL
    DB[:conn].execute(sql, self.name, self.id)

  end


end

require_relative "../config/environment.rb"
require 'pry'
class Student

  attr_accessor :name, :grade, :id

  def initialize(name, grade)
    @id
    @name=name
    @grade=grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name,grade)
    student = Student.new(name,grade)
    student.save
  end

  def self.new_from_db(array)
    student = Student.new(array[1],array[2])
    student.id=array[0]
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT id, name, grade FROM students WHERE name = ?
    SQL
    data = DB[:conn].execute(sql,name)[0]
    new_from_db(data)
  end

end

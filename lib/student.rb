require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id
  attr_reader
  def initialize (name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER)
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      sql = <<-SQL
        DROP TABLE IF EXISTS students
      SQL
      DB[:conn].execute(sql)
    end

    def save
      insert = <<-SQL
        INSERT INTO students(name, grade)
        VALUES (?,?)
        SQL
        update = <<-SQL
            UPDATE students SET name = ? WHERE id = ?
            SQL
      if DB[:conn].execute("SELECT * FROM students WHERE id = ?;", self.id).empty?
        DB[:conn].execute(insert, self.name, self.grade)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
      else
          DB[:conn].execute(update, self.name, self.id)
    end
  end

  def self.create(name, grade)
    name = Student.new(name,grade)
    name.save
  end

  def self.new_from_db(student)
    # student = DB[:conn].execute("SELECT * FROM students WHERE id = ?;", self.id)[0]
    student = Student.new(student[1],student[2], student[0])


  end

  def self.find_by_name(name)
    student = DB[:conn].execute("SELECT * FROM students WHERE name = ?;", name)[0]
    self.new_from_db(student)
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  end

  def update
    update = <<-SQL
        UPDATE students SET name = ? WHERE id = ?
        SQL
        DB[:conn].execute(update, self.name, self.id)
  end
end

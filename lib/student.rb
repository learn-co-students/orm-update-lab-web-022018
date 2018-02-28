require_relative "../config/environment.rb"

class Student
	attr_accessor :name, :grade
	attr_reader :id

	def initialize(name, grade, id=nil)
		@name = name
		@grade = grade
		@id = id
	end

	def self.create_table
		sql = <<-SQL
			create table if not exists students (
				id integer primary key,
				name text,
				grade text
			)
		SQL

		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL
			drop table if exists students
		SQL

		DB[:conn].execute(sql)
	end

	def save
		if self.id
			update
		else
			sql = <<-SQL
				insert into students (name, grade)
				values (?, ?)
			SQL

			DB[:conn].execute(sql, @name, @grade)
			@id = DB[:conn].execute("select last_insert_rowid() from students")[0][0]
		end
	end

	def self.create(name, grade, id=nil)
		student = Student.new(name, grade, id)
		student.save
		student
	end

	def self.new_from_db(row)
		self.create(row[1], row[2], row[0])
	end

	def self.find_by_name(name)
		sql = <<-SQL
			select * from students
			where name = ?
		SQL

		self.new_from_db(DB[:conn].execute(sql, name)[0])
	end

	def update
		sql = <<-SQL
			update students
			set name = ?, grade = ?, id = ?
			where id = ?
		SQL

		DB[:conn].execute(sql, @name, @grade, @id, @id)
	end



end

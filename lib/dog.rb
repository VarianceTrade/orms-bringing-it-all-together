class Dog

    attr_accessor :name, :breed

    attr_reader :id

    def initialize(id:nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        
        DB[:conn].execute(sql, name, breed)

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        return self
        # still really confused with the id
    end

    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
    end

    def self.new_from_db(row)
        new_dog = Dog.new(id:row[0], name:row[1], breed:row[2])
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL

        rows = DB[:conn].execute(sql, id)

        rows.map do |row|
            Dog.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? and breed = ?
        SQL

        rows = DB[:conn].execute(sql, name, breed)
        if rows.length == 0 # did not find match
            Dog.create(name: name, breed: breed)
        else # did find a match
            Dog.new_from_db(rows.first)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL
        rows = DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end




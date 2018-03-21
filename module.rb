module Database

    def connect()
        db = SQLite3::Database.new("database.db")
        return db
    end

    def show_inventory()
        db = connect()
        result = db.execute("SELECT id, name, quantity, price FROM fish")
        return result
    end

    def get_fishname_from_id(id:)
        db = connect()
        fishname = db.execute("SELECT name FROM fish WHERE id = ?", [id]).first
        return fishname
    end

    def add_fish(fish_amount:,id:)
        
        db = connect()
        old_value = db.execute("SELECT quantity FROM fish WHERE id = ?", [id])
        fish_amount = fish_amount.to_i
        old_value = old_value[0][0].to_i
        p "Old Value is #{old_value}"
        new_value = old_value + fish_amount
        p "New Value is #{old_value} + #{fish_amount} = #{new_value}"
        db.execute("UPDATE fish SET quantity = #{new_value} WHERE id =?",[id])
    end

    def change_price(fish_price:,id:)
        
        db = connect()
        old_value = db.execute("SELECT price FROM fish WHERE id = ?", [id])
        fish_price = fish_price.to_i
        old_value = old_value[0][0].to_i
        p "Old Value is #{old_value}"
        new_value = old_value + fish_price
        p "New Value is #{old_value} + #{fish_price} = #{new_value}"
        db.execute("UPDATE fish SET price = #{new_value} WHERE id =?",[id])
    end
        

    def create_admin(username:,password:)
        db = connect()
        db.execute("INSERT INTO admin(username,password_digest) VALUES(?,?)", [username, password])
    end

    def create_customer(username:,password:)
        db = connect()
        db.execute("INSERT INTO customer(username,password_digest) VALUES(?,?)", [username, password])
    end

    def get_password_digest(username:, type_of_user:)
        db = connect()
        result = db.execute("SELECT password_digest FROM #{type_of_user} WHERE username = ?",[username])
        return result[0][0]   
    end
end
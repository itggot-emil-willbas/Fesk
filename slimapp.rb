
require 'rubygems'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'
require_relative 'module.rb'
include Database

enable :sessions

#Varför kan man inte routa till '/mainadmin' om man först reggar, sen loggar in?

get('/') do
    slim(:index)
end

get('/logout') do
    session.clear
    redirect('/')
end

get('/adminregister') do
    slim(:adminregister)
end

get('/customerregister') do
    slim(:customerregister)
end

get('/mainadmin') do
    slim(:mainadmin)
end

get('/maincustomer') do
    slim(:maincustomer)
end

get('/inventory/:id/edit_amount') do
    fish_id = params[:id]
    fishname = get_fishname_from_id(id:fish_id)

    if session[:type_of_user] != "admin"
        session[:error] = "You are not logged in as admin."
        redirect('/error')    
    end

    slim(:edit_fish_amount, locals:{fish_id:fish_id,fishname:fishname})
    
end

get('/inventory/:id/edit_price') do
    fish_id = params[:id]
    fishname = get_fishname_from_id(id:fish_id)

    if session[:type_of_user] != "admin"
        session[:error] = "You are not logged in as admin."
        redirect('/error')    
    end

    slim(:edit_fish_price, locals:{fish_id:fish_id,fishname:fishname})
    
end

get('/error') do
    errormsg = session[:error]
    type_of_user = session[:type_of_user]
    
    if type_of_user == "admin"
        linktxt = "adminregister"
    else
        if type_of_user == "customer"
            linktxt = "customerregister"
        else
            linktext = "/"
            errormg = "Something went terribly bad. You are neither Admin or Customer. Are you a fish?"
        end
    end
    slim(:error, locals:{errormsg:errormsg,linktxt:linktxt})
end



get('/inventory') do
    
    result = show_inventory()
    test = "TEst"
    slim(:inventory, locals:{result:result, test:test})
end

post('/login') do 
    
    if params[:type_of_user] == nil
        session[:error] = "Please choose 'Admin' or 'Customer'"
        redirect('/error')
    end

    session[:type_of_user] = params[:type_of_user]
    username = params[:username]
    password = params[:password]
    type_of_user = session[:type_of_user]
    password_digest = get_password_digest(username:username,type_of_user:type_of_user)
    
    if password.length > 0 && username.length > 0 
        if BCrypt::Password.new(password_digest) == password && type_of_user == "admin" 
            redirect('/mainadmin')
        else
            if BCrypt::Password.new(password_digest) == password && type_of_user == "customer" 
                redirect('/maincustomer')
            else
                redirect('/')
            end
            
        end
    else
        redirect('/')
    end


end

post('/adminregister') do
    session[:type_of_user] = "admin"
    username = params[:username]
    secret_word = params[:secret_word]
    password = params[:password]
    confirm = params[:confirm]

    if password.length > 0 && username.length > 0 && secret_word == "fisk"
        if password == confirm
            password_digest = BCrypt::Password.create(password)
            begin
                create_admin(username:username,password:password_digest)
            rescue SQLite3::ConstraintException
                session[:error] = "Username already exists, please choose another"
                redirect('/error')
            end
        else
            session[:error] = "Password and confirmation don't match, plz try again"
            redirect('/error')
        end
        redirect('/mainadmin')
    else
        session[:error] = "Please fill in the form and type the secret word. Hint: f _ _ _"
        redirect('/error')
    end

    

end

post('/customerregister') do
    session[:type_of_user] = "customer"
    username = params[:username]
    password = params[:password]
    confirm = params[:confirm]

    if password.length > 0 && username.length > 0 
        if password == confirm
            password_digest = BCrypt::Password.create(password)
            begin
                create_customer(username:username,password:password_digest)
            rescue SQLite3::ConstraintException
                session[:error] = "Username already exists, please choose another"
                redirect('/error')
            end
        else
            session[:error] = "Password and confirmation don't match, plz try again"
            redirect('/error')
        end
        redirect('/maincustomer')
    else
        session[:error] = "Please fill in the form"
        redirect('/error')
    end
end

post('/inventory/:id/edit_amount') do
    fish_amount = params[:number]
    fish_id = params[:id] #Tänker jag fel här?
    add_fish(fish_amount:fish_amount,id:fish_id)
    redirect('/inventory')
end

post('/inventory/:id/edit_price') do
    fish_price = params[:number]
    fish_id = params[:id] #Tänker jag fel här?
    change_price(fish_price:fish_price,id:fish_id)
    redirect('/inventory')
end
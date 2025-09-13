# encoding: utf-8
Rozario::App.controllers :user_accounts do

  get :index do
    puts "get :index do user_account.rb"
  end

  get :new do
    puts "get :new do user_account.rb"
    if current_account
      redirect "/"
    else
      @user_account = UserAccount.new
      render 'user_accounts/new'
    end
  end

  post :create do
    puts "  post :create do user_account.rb"
    udata = params[:user_account]
    udata["role"] = "user"

    udata["discount_code"] = ""
    udata["discount_code"] += udata["discount_code1"].to_s
    udata["discount_code"] += udata["discount_code2"].to_s
    udata["discount_code"] += udata["discount_code3"].to_s

    udata.delete("discount_code1")
    udata.delete("discount_code2")
    udata.delete("discount_code3")

    @user_account = UserAccount.new(udata)
    @user_account.gen_subscribe_code
    if @user_account.save
      ImportUser.where(:email => @user_account.email).destroy_all
      @title = pat(:create_title, :model => "user_account #{@user_account.id}")
      if params[:emb]
        ua = UserAccount.authenticate(udata[:email], udata[:password])
        set_current_account(ua)
        redirect 'cart/checkout'
      else
        flash.now[:success] = pat(:create_success, :model => 'user_account')
        render 'sessions/new'
      end
    else
      @title = pat(:create_title, :model => 'user_account')
      flash.now[:error] = "Ошибка: проверьте правильность заполнения всех полей"
      if params[:emb]
        flash[:notice] = "Ошибка: проверьте правильность заполнения всех полей"
        redirect back
      else
        render 'user_accounts/new'
      end
    end
  end
  
  post :creates, :csrf_protection => false do
    puts "  post :creates, :csrf_protection => false do user_account.rb"
    require 'json'
    params = JSON.parse(request.env["rack.input"].read)
    p params
    udata = params
    udata["role"] = "user"

    udata["discount_code"] = ""
    udata["discount_code"] += udata["discount_code1"].to_s
    udata["discount_code"] += udata["discount_code2"].to_s
    udata["discount_code"] += udata["discount_code3"].to_s

    udata.delete("discount_code1")
    udata.delete("discount_code2")
    udata.delete("discount_code3")

    @user_account = UserAccount.new(udata)
    @user_account.gen_subscribe_code
    if @user_account.save
      ImportUser.where(:email => @user_account.email).destroy_all
      @title = pat(:create_title, :model => "user_account #{@user_account.id}")
      ua = UserAccount.authenticate(udata["email"], udata["password"])
      p ["AUTH", ua]
      p ["SET ACC", set_current_account(ua)]
      res = "Ok"
    else
      p @user_account.errors
      @title = pat(:create_title, :model => 'user_account')
      halt 403
      res = "Error"
    end
    content_type :json
    "{'Result': #{res}}".to_json
  end

  get :profile do
    puts "  get :profile do user_account.rb"
    if current_account
      @active_orders = Order.where(:useraccount_id => current_account.id).where('user_datetime > ?', DateTime.now).order("created_at DESC")
      @old_orders = Order.where(:useraccount_id => current_account.id).where('user_datetime <= ?', DateTime.now).order("created_at DESC")
      render "user_accounts/profile"
    else
      redirect 'sessions/new'
    end
  end

  get :edit_profile do
    puts "  get :edit_profile do user_account.rb"
    @user_account = current_account
    render 'user_accounts/edit'
  end

  put :update do
    puts "  put :update do user_account.rb"

    params[:user_account]["discount_code"] = ""
    params[:user_account]["discount_code"] += params[:user_account]["discount_code1"].to_s
    params[:user_account]["discount_code"] += params[:user_account]["discount_code2"].to_s
    params[:user_account]["discount_code"] += params[:user_account]["discount_code3"].to_s
    params[:user_account].delete("discount_code1")
    params[:user_account].delete("discount_code2")
    params[:user_account].delete("discount_code3")

    @user_account = UserAccount.find(params[:id])
    if @user_account
      if @user_account.update_attributes(params[:user_account])
        flash[:success] = "Профиль успешно изменен"
        redirect url(:user_accounts, :profile)
      else
        flash.now[:error] = "Не удалось обновить профиль"
        render 'user_accounts/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'UserAccount', :id => "#{params[:id]}")
      halt 404
    end
  end

  post :message do
    puts "  post :message do user_account.rb"
    pf = !params[:file].blank?
    if pf
      name = params[:file][:filename]
      datafile = params[:file]
    end
    msg_body = "Пользователь: " + current_account.surname + "\nЭл. почта: #{current_account.email}\nТелефон: #{current_account.tel}" + "\n" + "Текст сообщения:\n" + params[:msg]
      email do
        from "no-reply@#{CURRENT_DOMAIN}"
        to ENV['ORDER_EMAIL'].to_s
        subject "Сообщение из админки"
        body msg_body
        add_file(:filename => name.to_s, :content => File.read(datafile[:tempfile])) if pf
      end
    flash[:notice] = 'Спасибо, Ваше сообщение отправлено.'
    redirect url(:user_accounts, :profile)
  end

  get :unsubscribe do
    puts "  get :unsubscribe do user_account.rb"
    user = UserAccount.where(:email => params[:email], :subscribe_code => params[:code]).first
    if user.nil?
      flash[:error] = "Отписаться от рассылки: Неверная ссылка"
    else
      user.subscribe = false
      user.save
      flash[:notice] = "Вы отписались от рассылки"
    end
    redirect "/user_accounts/profile"
  end
  
  get :iunsubscribe do
    puts "  get :iunsubscribe do user_account.rb"
    user = ImportUser.where(:email => params[:email], :subscribe_code => params[:code]).first
    if user.nil?
      flash[:error] = "Отписаться от рассылки: Неверная ссылка"
    else
      user.subscribe = false
      user.save
      flash[:notice] = "Вы отписались от рассылки"
    end
    redirect "/user_accounts/profile"
  end
  
  get :subscribe do
    puts "  get :subscribe do user_account.rb"
    user = UserAccount.find_by_id(current_account.id)
    if user.nil?
      redirect "/sessions/new"
    else
      user.subscribe = true
      user.save
      flash[:notice] = "Вы подписались на рассылку"
    end
    redirect "/user_accounts/profile"
  end

  get :payment do
    puts "  get :payment do user_account.rb"
    order = Order.find(params[:order])
    @del_price = order.delivery_price
    @total_summ = order.total_summ
    ret = Order_product.where('id = ' + order.id.to_json + '')
    a = UserAccount.new
    @include_tax = a.user_json(ret, @del_price)
    render 'user_accounts/payment'
  end

end

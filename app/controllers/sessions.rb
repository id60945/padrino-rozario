# encoding: utf-8
Rozario::App.controllers :sessions do
  get :new do
    if current_account
      redirect "/"
    else
      render 'sessions/new'
    end
  end

  post :creates, :csrf_protection => false do
    params = JSON.parse(request.env["rack.input"].read)
    if user_account = UserAccount.authenticate(params["email"], params["password"])
      set_current_account(user_account)
      session[:user_id] = user_account.id
      res = "Ok"
    else
      res = "Error"
      halt 403
    end
    content_type :json
    "{'Result': #{res}}".to_json
  end

  post :create, :csrf_protection => false do
    if user_account = UserAccount.authenticate(params[:email], params[:password])
      set_current_account(user_account)
      session[:user_id] = user_account.id
      if params[:redirect_url]
        redirect params[:redirect_url]
      else
        redirect url(:user_accounts, :profile)
      end
    else
      params[:email], params[:password] = h(params[:email]), h(params[:password])
      flash[:notice] = pat('login.error')
      redirect back
      # erb 'error'
    end
  end

  get :destroy do
    session[:user_id] = nil
    set_current_account(nil)
    redirect "/"
  end

  get :password_lost do
    render 'sessions/password_lost'
  end

  post :password_lost do
    # получим юзера с таким адресом
    ua = UserAccount.where(email: params[:email]).first
    if ua
      # сгенерим токен
      ua.recovery_token = SecureRandom.urlsafe_base64(24)
      ua.save
      # отправим письмо со ссылкой на восстановление по токену
      email do
        content_type :html
        from "Rozario <no-reply@#{CURRENT_DOMAIN}>"
        to ua.email
        subject "#{CURRENT_DOMAIN} — восстановление пароля"
        body "<!DOCTYPE html><html><head><meta charset='utf-8'></head><body>Здравствуйте.<br><br>Мы получили запрос на восстановление Вашего пароля.<br>Если Вы желаете восстановить пароль на сайте #{CURRENT_DOMAIN}, то перейдите по <a href=\"https://#{CURRENT_DOMAIN}/sessions/password_recover?token=#{ua.recovery_token}\">ссылке<a> и следуйте инструкциям.</body></html>"
      end
      render 'sessions/password_lost_ok'
    else
      flash[:notice] = "Ошибка! Пользователь с таким адресом эл. почты не зарегистрирован."
      redirect back
    end
  end

  get :password_recover do
    if params[:token]
      ua = UserAccount.where(recovery_token: params[:token]).first
      if ua
        render 'sessions/password_recover'
      else
        redirect url(:sessions, :new)
      end
    else
      redirect url(:sessions, :new)
    end
  end

  post :password_recover do
    if params[:recovery_token]
      ua = UserAccount.where(recovery_token: params[:recovery_token]).first
      if ua
        if ua.update_attributes(params[:user_account])
          # удалим токен
          ua.recovery_token = nil
          ua.save
          flash[:notice] = "Пароль изменен!<br>Теперь Вы можете войти, используя новый пароль."
          redirect url(:sessions, :new)
        else
          flash[:notice] = "Не удалось обновить. Пароли должны совпадать. Минимальная длина — 4 символа."
          redirect back
        end
      else
        flash[:notice] = "Не удалось обновить пароль"
        redirect back
      end
    end
  end
  get :payment do
    if session[:odata]
      odata = JSON.parse(session[:odata])
      @total_summ = odata["cart_summ"].to_s
      session[:odata] = nil
      key = Order.last.id
      @orders = Order.new()
      @include_tax = @orders.parse_price(key).to_s
      render 'sessions/payment', :layout => 'application'
    else
      redirect '/cart'
    end
  end
end

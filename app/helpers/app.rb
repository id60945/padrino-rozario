# encoding: utf-8

# What the fuck is this file doing here?

module Rozario
  class Admin < Padrino::Application
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers
    register Padrino::Admin::AccessControl

    ##
    # Application configuration options
    #
    # set :raise_errors, true         # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true          # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true      # Shows a stack trace in browser (default for development)
    # set :logging, true              # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, "foo/bar"   # Location for static assets (default root/public)
    # set :reload, false              # Reload application files (default in development)
    # set :default_builder, "foo"     # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, "bar"         # Set path for I18n translations (default your_app/locales)
    # disable :sessions               # Disabled sessions by default (enable if needed)
    # disable :flash                  # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout              # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)

    set :admin_model, 'Account'
    set :login_page,  '/admin/sessions/new'

    set :protection, false
    #set :protect_from_csrf, false
    #set :allow_disabled_csrf, true

    enable :sessions
    enable :authentication
    disable :store_location

    access_control.roles_for :any do |role|
      if PADRINO_ENV == 'development'; role.allow '/'
      else;                            role.protect '/'; end
      role.allow '/sessions'
    end

    if PADRINO_ENV == 'development'
      access_control.roles_for :any do |role|
        role.project_module :menus_on_main,  '/menus_on_main'
        role.project_module :discounts,      '/discounts'
        role.project_module :delivery,       '/delivery'
        role.project_module :regions,        '/regions'
        role.project_module :categorygroups, '/categorygroups'
        role.project_module :complects,      '/complects'
        role.project_module :pages,          '/pages'
        role.project_module :categories,     '/categories'
        role.project_module :products,       '/products'
        role.project_module :news,           '/news'
        role.project_module :articles,       '/articles'
        role.project_module :photos,         '/photos'
        role.project_module :albums,         '/albums'
        role.project_module :comments,       '/comments'
        role.project_module :contacts,       '/contacts'
        #role.project_module :options,       '/options'
        role.project_module :clients,        '/clients'
        role.project_module :accounts,       '/accounts'
        role.project_module :seo,            '/seo'
        role.project_module :payment,        '/payment'
        role.project_module :payment,        '/seo_texts'
      end
    else
      access_control.roles_for :admin do |role|
        role.project_module :menus_on_main,  '/menus_on_main'
        role.project_module :discounts,      '/discounts'
        role.project_module :delivery,       '/delivery'
        role.project_module :regions,        '/regions'
        role.project_module :categorygroups, '/categorygroups'
        role.project_module :complects,      '/complects'
        role.project_module :pages,          '/pages'
        role.project_module :categories,     '/categories'
        role.project_module :products,       '/products'
        role.project_module :news,           '/news'
        role.project_module :articles,       '/articles'
        role.project_module :photos,         '/photos'
        role.project_module :albums,         '/albums'
        role.project_module :comments,       '/comments'
        role.project_module :contacts,       '/contacts'
        #role.project_module :options,       '/options'
        role.project_module :clients,        '/clients'
        role.project_module :accounts,       '/accounts'
        role.project_module :seo,            '/seo'
        role.project_module :payment,        '/payment'
        role.project_module :payment,        '/seo_texts'
      end
    end

    # Custom error management
    error(403) { @title = "Error 403"; render('errors/403', :layout => :error) }
    error(404) { @title = "Error 404"; render('errors/404', :layout => :error) }
    error(500) { @title = "Error 500"; render('errors/500', :layout => :error) }
  end
end


def prod_price
  @product_price = ActiveRecord::Base.connection.execute("SELECT cart from orders ORDER BY id DESC LIMIT 1;").to_a
end

#def check_session
#  if request.session[:mdata] 
#    session[:mdata]
#    sql1 = "INSERT INTO overdateuser (isnew, dat) VALUES (1);" 
#    1_site = ActiveRecord::Base.connection.execute(sql1) 
#  else
#    sql0 = "INSERT INTO overdateuser (isnew) VALUES (0);" 
#    0_site = ActiveRecord::Base.connection.execute(sql0)
#    session[:mdata] = Date.current
#  end
#end

def pretty_date(time) # Форматировать дату
  time.strftime("%d %b %Y")
end
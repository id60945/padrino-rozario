# encoding: utf-8
Rozario::App.controllers :smiles do
  get('/gettt/:page/?') do
    puts "get ('/smiles/gettt/:page/?') app.rb"
    # offset = params[:page].to_i * 10 - 10
    @offset = params[:page].to_i * 12 - 12
    @posts = Smile.order('created_at DESC').offset(@offset).limit(12)
    @lastget = @offset >= Smile.count - 12
    erb :'smiles/get'
  end

  # отобразить форму для создания нового поста
  get ('/create/?') do
    erb :'smiles/create'
  end

  # взять параметры из формы и сохранить пост

  get ('/?') do
    @tt = false
    @postsss = Smile.order('created_at DESC').limit(12)
    @lastget = @postsss.size < 12
    get_seo_data('smiles_page', nil, true)
    erb :'smiles/index'
  end

  get ('/product/:id/?') do
    @pid = params[:id]
    @tt = true
    @postsss = Smile.all
    @result = []
    @postsss.each do |smile|
      order = JSON.parse(smile.json_order)
      order.each do |prdct|
        @result[@result.size] = smile if prdct[1]['id'] == @pid
      end
    end

    @lastget = @result.size < 12

    @postsss = @result
    get_seo_data('smiles_page', nil, true)
    erb :'smiles/index'
  end

  get ('/product/:pid/:sid/?') do
    @dsc = DscntClass.new.some_method
    @pid = params[:pid]
    @id = params[:sid]
    @postsss = Smile.all
    @result = []
    @postsss.each do |smile|
      order = JSON.parse(smile.json_order)
      order.each do |prdct|
        @result[@result.size] = smile if prdct[1]['id'] == params[:pid]
      end
    end
    @postsss = @result
    i = 0; for item in @postsss
             if item.id == @id.to_i
               if !@postsss[i + 1]
                 @p_prev = @postsss[i - 1].id
                 @p_next = @postsss[0].id
               else
                 @p_prev = @postsss[i - 1].id
                 @p_next = @postsss[i + 1].id
               end
               break
             end
             i += 1
    end
    erb :'smiles/show'
  end

  get ('/gettttt/:page/?') do
    @product = Product.find_by_id(params[:id])
    @postsss = Smile.all
    @result = []
    @offset = params[:page].to_i * 12 - 12
    i = 0
    @postsss.each do |smile|
      i += 1
      order = JSON.parse(smile.json_order)
      order.each do |prdct|
        if prdct[1]['id'] == params[:id] && i < @offset
          @result[@result.size] = smile
        end
      end
    end

    @postsss = @result

    @lastget = @result.count >= 12

    erb :'smiles/get'
  end

  get ('/:slug/?') do
    if request.session[:mdata].nil?
      current_date = '2019-03-09'
      session[:mdata] = '2019-03-09'
    else
      current_date = request.session[:mdata]
    end
    date_begin = Date.new(2019, 3, 23).to_s
    date_end = Date.new(2019, 3, 25).to_s
    value = ''
    if (current_date.to_s >= date_begin) && (current_date.to_s <= date_end)
      value = 'true'
      ProductComplect.check(value)
    else
      value = 'false'
      ProductComplect.check(value)
      # @change = ProductComplect.new()
      # @change.check(value)
    end
    @dsc = DscntClass.new.some_method
    smile = Smile.find_by_slug(params[:slug])
    @id = smile.id if smile.present?
    @id = Smile.find_by_id(params[:slug]).id if @id.nil?
    @posts = Smile.order('created_at DESC')
    i = 0
    for item in @posts
      if item.id == @id.to_i
        if !@posts[i + 1]
          @p_prev = @posts[i - 1].id
          @p_next = @posts[0].id
        else
          @p_prev = @posts[i - 1].id
          @p_next = @posts[i + 1].id
        end
        break
      end
      i += 1
    end
    "https://" + request.env['HTTP_HOST'] +  '/smiles/' + Smile.find_by_id(@id).slug if Smile.find_by_id(@id).slug
    get_seo_data('smiles', Smile.find_by_id(@id).seo_id)
    erb :'smiles/show'
  end
end

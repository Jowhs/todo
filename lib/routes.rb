before do
  redirect '/login' if !request.path_info.split('/')[1] == 'login' && session[:user_id].nil?
end

get '/?' do
  slim :index
end

get '/dashboard?' do
  @user = User.first(id: session[:user_id])
  if @user.nil?
    redirect '/login'
  else
    slim :dashboard
  end
end

get '/lists' do
  # binding.pry
  @lists = List.all
  user = User.first(id: session[:user_id])
  @lists = List.association_join(:permissions).where(user_id: user.id)
  slim :lists
end

get '/lists/:id' do
  # binding.pry
  @user = User.first(id: session[:user_id])
  @list = List.first(id: params[:id])
  @ordered_list = @list.items_dataset.order(Sequel.desc(:starred))
  slim :list_id
end

post '/lists/:id' do
  # binding.pry
  @user = User.first(id: session[:user_id])
  @list = List.first(id: params[:id])
  Comment.new_comment @list.id, @user.id, params[:comments]
  redirect "/lists/#{@list.id}"
end

get '/new/?' do
  @user = User.first(id: session[:user_id])
  if @user.nil?
    redirect '/login'
  else
    slim :new_list
  end
end

# create list
post '/new/?' do
  # binding.pry
  @user = User.first(id: session[:user_id])
  List.new_list params[:name], params[:items], @user
  # list = List.create(params[:name], params[:items], user)
  redirect '/lists'
end

get '/edit/:id/?' do
  # binding.pry
  @user = User.first(id: session[:user_id])
  @list = List.first(id: params[:id])
  can_edit = true

  if @list.nil?
    can_edit = false
  elsif @list.shared_with == 'public'
    @user = User.first(id: session[:user_id])
    permission = Permission.first(list: @list, user: @user)
    can_edit = false if permission.nil? || permission.permission_level == 'read_only'
  end

  if can_edit
    slim :edit_list, locals: { list: @list }
  else
    slim :error, locals: { error: 'Invalid permissions' }
  end
end

post '/edit/?' do
  # binding.pry
  @user = User.first(id: session[:user_id])
  list_name = params[:lists][0]['name']
  list_id = params[:lists][0][:id].to_i
  items = params[:items]
  List.edit_list list_id, list_name, items, @user
  redirect '/lists'
end

# this route allows delete lists
get '/delete/:id' do
  # binding.pry
  @user = User.first(id: session[:user_id])
  list_id = params[:id]
  List.del(list_id)
  redirect '/lists'
end

get '/delete/comment/:id' do
  # binding.pry
  @user = User.first(id: session[:user_id])
  comment_id = params[:id].to_i
  current_date = Time.now
  comment = Comment.where(id: comment_id).first
  creation_date = comment.created_at
  Comment.del_comment(comment_id) if current_date < creation_date + 15 * 60
  redirect "/lists/#{comment.list_id}"
end

# post '/edit/:id' do
# binding.pry
#  @user = User.first(id: session[:user_id])
#  item = Item.first(id: params[:id]).destroy
#  redirect "/edit/#{item.list.id}"
# end

post '/permission/?' do
  @user = User.first(id: session[:user_id])
  list = List.first(id: params[:id])
  can_change_permission = true

  if list.nil?
    can_change_permission = false
  elsif list.shared_with != 'public'
    permission = Permission.first(list: list, user: @user)
    can_change_permission = false if permission.nil? || permission.permission_level == 'read_only'
  end

  if can_change_permission
    list.permission = params[:new_permissions]
    list.save
    current_permissions = Permission.first(list: list)
    current_permissions.each(&:destroy)

    if params[:new_permissions] == 'private' || parms[:new_permissions] == 'shared'
      user_perms.each do |perm|
        u = User.first(perm[:user])
        Permission.create(list: list, user: u, permission_level: perm[:level], created_at: Time.now, updated_at: Time.now)
      end
    end

    redirect request.referer
  else
    slim :error, locals: { error: 'Invalid permissions' }
  end
end

get '/signup/?' do
  if session[:user_id].nil?
    slim :signup
  else
    slim :error, locals: { error: 'Please log out first' }
  end
end

post '/signup/?' do
  md5sum = Digest::MD5.hexdigest params[:password]
  User.create(name: params[:name], password: md5sum)
  redirect '/login'
end

get '/login/?' do
  if session[:user_id].nil?
    slim :login
  else
    slim :error, locals: {error: 'Please log out first'}
  end
end

post '/login/?' do
  md5sum = Digest::MD5.hexdigest params[:password]
  @user = User.first(name: params[:name], password: md5sum)
  if @user.nil?
    slim :error, locals: { error: 'Invalid login credentials' }
  else
    session[:user_id] = @user.id
    redirect '/dashboard'
  end
end

get '/logout/?' do
  session[:user_id] = nil
  redirect '/login'
end

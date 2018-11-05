class UsersController < ApplicationController
	skip_before_action :authenticate_request, only: %i[login register]
	
	# POST /register
  def register
    @user = User.create(user_params)
   if @user.save
    response = { message: 'User created successfully'}
    render json: response, status: :created 
   else
    render json: @user.errors, status: :unprocessable_entity
   end 
  end

  def login
    authenticate params[:email], params[:password]
  end

  def test
    render json: {
          message: 'You have passed authentication and authorization test'
        }
  end

  private

  def user_params
    params.permit(
      :name,
      :email,
      :password
    )
  end

  def authenticate(email, password)
    command = AuthenticateUser.call(email, password)

    if command.success?
      @user = User.find_by email:email
      render json: {
        access_token: command.result,
        message: 'Login Successful',
        user: {
          username: @user.name,
          email: @user.email
        }
      }
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end
end

class Api::V1::AuthController < ApplicationController
    skip_before_action :authorize, only: [:create, :validate]
    
    def create
        user = User.find_by(email: user_login_params[:email])
        if user && user.authenticate(user_login_params[:password])
            render json: { user: UserSerializer.new(user), token: issue_token(user_id: user.id) }, status: :accepted
        else
            render json: { message: 'Invalid email or password' }, status: :unauthorized
        end
    end

    def data
        user = @current_user
        current_home = User.find(user.id).home
        current_users = User.all.select do |current_user| 
            current_user.home_id === user.home.id
        end
        current_bills = Bill.all.select do |bill| 
            bill.home_id === user.home.id
        end
        current_bill_splits = BillSplit.all.select do |billsplit| 
            billsplit.user_id === user.id
        end
        all_bill_splits = BillSplit.all.select do |bill_split|
            current_bills.select do |current_bill|
                current_bill.id === bill_split.bill_id
            end
        end
        current_tasks = Task.all.select do |task|
            task.user_id === user.id
        end
        all_current_tasks = Task.all.select do |task|
            task.home_id === current_home.id
        end
        current_essentials = Essential.all.select do |essentail|
            essentail.home_id === user.home.id
        end
        if user
            render json: {
                home: current_home,
                users: current_users,
                bills: current_bills,
                bill_splits: current_bill_splits,
                tasks: current_tasks,
                all_tasks: all_current_tasks,
                all_bill_splits: all_bill_splits,
                essentials: current_essentials
            }
        else
            render json: {error: "Data Not Avaliable"}
        end
    end

    def validate
        user = @current_user
        if user
            render json: { user: UserSerializer.new(user), token: issue_token(user_id: user.id)}, status: :accepted
        else 
            render json: { errors: 'invalid token '}, status: :unauthorized
        end
    end

    private

    def user_login_params
        params.require(:user).permit(:email, :password)
    end
end

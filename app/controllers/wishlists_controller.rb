class WishlistsController < ApplicationController
  before_action :get_items, only: [:show, :edit, :update]
  before_action :get_wishlist, only: [:show, :edit, :update, :destroy]
  before_action :get_user, only: [:new, :create, :show, :edit, :update]

  def new
    create
  end

  def create
    @wishlist = Wishlist.new(user_id: @user.id, name: "user_#{@user.id}_wishlist")
    @wishlist.save

    redirect_to edit_user_wishlist_path(@user.id, @wishlist)
  end

  def show
  end

  def edit
    @wishlist_items = 
      @wishlist.items.reduce([]) do |item_attrs, item|
        item_attrs.push(
          OpenStruct.new(
            {
              id: item.id,
              name: item.name,
              url: item.url,
              price: item.price,
              image: item.image(:original),
              short_url: (item.url.present? ? item.short_url : ''),
              notes: item.notes,
              purchased: item.purchased,
            }
          )
        )
      end
  end

  def update
    if @wishlist.update_attributes(wishlist_params)
      redirect_to edit_user_wishlist_path(@user.id, @wishlist)
    else
      redirect_to wishlists_path
    end
  end

  def reminder
    user_email = User.find(params[:user_id]).email

    if NotificationMailer.reminder_mail(params[:user_id]).deliver
      flash[:notice] = "Awesome! An reminder has been sent to #{user_email}."
    else
      flash[:error] = "Uh oh. Something went wrong. Try again."
    end

    redirect_back fallback_location: :show, id: params[:id]
  end
  
  private

  def wishlist_params
    params.require(:wishlist).permit(:id, :user_id, :name, :membership_id, items_attributes: [:id, :name, :description, :price, :notes, :url])
  end

  def get_wishlist
    @wishlist = Wishlist.find_by(id: params[:id]).decorate
    redirect_to root_url unless @wishlist
  end

  def get_items
    @items = Wishlist.find(params[:id]).items unless @wishlist.blank?
  end

  def check_user_memberships
    accessible_wishlists = current_user.memberships.map {|membership| membership.wishlist_id}
    if accessible_wishlists.include? params[:id].to_i
      yield
    else
      redirect_to wishlists_path
      Rails.logger.debug 'User does not have access to this wishlist'
    end
  end

end

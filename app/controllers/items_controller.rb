# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ItemsController < ApplicationController
  include Controllers::TagSearch

  before_filter :set_item, :only => [:show, :edit, :update, :destroy]

  # GET /items
  def index
    search_items

    respond_to do |format|
      format.html
      format.json { render json: @items }
    end
  end

  # Search for income items
  # GET /items/search_income?term=:term
  def search_income
    @items = ItemQuery.new.income_search(params[:term]).limit(20)

    respond_to do |format|
      format.json { render json: @items }
    end
  end

  # Search for expense items
  # GET /items/search_expense?term=:term
  def search_expense
    @items = ItemQuery.new.expense_search(params[:term]).limit(20)

    respond_to do |format|
      format.json { render json: @items }
    end
  end

  # GET /items/1
  def show
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    @item = Item.new(stockable: true)
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.xml
  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_ajax @item, notice: 'Se ha creado el ítem correctamente.'
    else
      render 'new'
    end
  end

  # PUT /items/1
  def update
    if @item.update_attributes(item_params)
      flash[:notice] = "Se actualizo correctamente el ítem."
      redirect_ajax @item
    else
      render :edit
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item.destroy

    redirect_ajax @item
  end

private
  def set_item
    @item = Item.find(params[:id])
  end

  def search_items
    if search_term.present?
      @items = Item.search(search_term).includes(:unit).order('name asc').page(@page)
    else
      @items = Item.includes(:unit, :stocks).order('name asc').page(@page)
    end
    
    @items = @items.all_tags(*tag_ids)  if params[:search] && has_tags?
  end

  def item_params
    params.require(:item).permit(:code, :name, :active, :stockable,
                                 :for_sale, :price, :buy_price, :unit_id, :description)
  end
end

class TeamController < ApplicationController
  def index
    @teams = Team.all
  end

  def buysell
    @sell_order_for_this_team = []
    @buy_order_for_this_team = []
    Team.find(params[:t_id]).cards.each do |c|
      c.orders.where(is_complete: false, is_sell: true).each do |o|
        @sell_order_for_this_team.push(o)
      end
    end
 
    Order.where(is_complete: false, is_sell: false, buy_team_id: params[:t_id]).order('price desc').each do |o|
      @buy_order_for_this_team.push(o)
    end   
  end

  def buy
    t_id = params[:t_id]
    o = Order.find(params[:order_id].to_i)
    c = o.card
    u = o.seller
    flash[:success_notice] = "님아 돈이 없음"

    if current_user.coin < o.price
      puts "zxcvzxcv"
      redirect_to "/team/buysell/#{t_id}"
    else
      Card.update(c.id, user_id: current_user.id)
      Order.update(o.id, buyer_id: current_user.id, is_complete: true)

      if current_user.id != u.id
        u.coin = u.coin + o.price
        u.save
        coin = current_user.coin
        User.update(current_user.id, coin: coin - o.price)
      end

      flash[:success_notice] = "카드가 구매되었습니다"
      redirect_to "/team/buysell/#{t_id}"
    end
  end

  def sell
    t_id = params[:t_id]
    c = current_user.cards.where(team_id: t_id).first
    o = Order.find(params[:order_id].to_i)
    u = o.buyer
    flash[:success_notice] = "님아 이 팀에 대한 카드가 님한테 하나도 없음"

    if c.nil?
      puts "zxcvzxcv"
      redirect_to "/team/buysell/#{t_id}"
    else
      Card.update(c.id, user_id: u.id)
      Order.update(o.id, card_id: c.id, seller_id: current_user.id, buy_team_id: nil, is_complete: true)

      if current_user.id != u.id
        u.coin = u.coin - o.price
        u.save
        coin = current_user.coin
        User.update(current_user.id, coin: coin + o.price)
      end

      flash[:success_notice] = "카드가 팔렸습니다"
      redirect_to "/team/buysell/#{t_id}"
    end
  end
end

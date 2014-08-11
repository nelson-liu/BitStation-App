class SearchSuggestionsController < ApplicationController
  def user
    query = params[:query] || ''
    query.strip!

    if query.empty?
      render json: []
    else
      users = User.where('kerberos LIKE ? or name LIKE ? or name LIKE ?', query + '%', query + '%', '% ' + query + '%').limit(5).all.to_a
      render json: (users.map do |u|
        {
          'kerberos' => u.kerberos,
          'name' => u.name,
          'tokens' => u.name.split(' ') + [u.kerberos],
          'coinbase_account_linked' => !u.coinbase_account.nil?
        }
      end)
    end
  end
end

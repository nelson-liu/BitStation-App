class SearchSuggestionsController < ApplicationController
  include ActionView::Helpers::TagHelper
  include ApplicationHelper

  before_filter :ensure_signed_in_without_redirect, only: [:user]

  def user
    query = params[:query] || ''
    query.strip!

    if query.empty?
      render json: []
    else
      users = User.where('kerberos LIKE ? or name LIKE ? or name LIKE ?', query + '%', query + '%', '% ' + query + '%').limit(5).all.to_a
      users.map!(&:to_search_suggestion)

      contacts = current_user.contacts.select do |c|
        c.coinbase? ?
          false :
          ((/\b#{query}/i =~ c.name) || (/^#{query}/i =~ c.address))
      end.map(&:to_search_suggestion)

      suggestions = users + contacts
      suggestions.uniq! { |s| [s['type'], s['address']] }

      suggestions.each { |s| s['html'] = html_from_search_suggestion(s) }
      render json: suggestions
    end
  end

  private
    def html_from_search_suggestion(u)
      inner_content = content_tag(:span, u['name'] + ' ') + address_type_label(u['type'], :short, class: 'pull-right autocomplete-type')
      result = content_tag(:p, inner_content.html_safe, class: 'autocomplete_name')

      status_class, status_text = status_from_search_suggestion(u)
      result += content_tag(:p, status_text, class: "autocomplete-coinbase-link-status text-#{status_class}")

      result
    end

    def status_from_search_suggestion(u)
      if u['type'] == 'bitstation'
        user = User.find_by(kerberos: u['address'])
        if user
          if user.coinbase_account.nil?
            ['danger', 'No Coinbase account linked. ']
          else
            ['success', 'Coinbase account linked. ']
          end
        else
          ['danger', 'This user hasn\'t joined BitStation yet. ']
        end
      elsif u['type'] == 'external'
        ['warning', 'This is an external address. ']
      end
    end
end

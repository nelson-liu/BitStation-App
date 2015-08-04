class SearchSuggestionsController < ApplicationController
  include ActionView::Helpers::TagHelper
  include ApplicationHelper

  before_filter :ensure_signed_in_without_redirect, only: [:user]

  SEARCH_SUGGESTION_USER_LIMIT = 5

  def user
    query = params[:query] || ''
    query.strip!
    query.downcase!

    if query.empty?
      render json: []
    else
      suggestions = user_users(query)
      suggestions += user_contacts(query) unless suggestions.size >= SEARCH_SUGGESTION_USER_LIMIT
      suggestions += user_potentials(query) unless suggestions.size >= SEARCH_SUGGESTION_USER_LIMIT

      suggestions = suggestions.uniq { |s| s['address'] }.first(SEARCH_SUGGESTION_USER_LIMIT)
      suggestions.each { |s| s['html'] = html_from_search_suggestion(s) }

      render json: suggestions
    end
  end

  private
    def user_users(query)
      u = User.arel_table
      users = User.where(u[:kerberos].matches(query + '%').or(u[:name].matches(query + '%').or(u[:name].matches('% ' + query + '%')))).limit(SEARCH_SUGGESTION_USER_LIMIT).all.to_a
      users.map!(&:to_search_suggestion)
    end

    def user_contacts(query)
      current_user.contacts.select do |c|
        ((/\b#{query}/i =~ c.name) || (/^#{query}/i =~ c.address))
      end.first(SEARCH_SUGGESTION_USER_LIMIT).map(&:to_search_suggestion)
    end

    def user_potentials(query)
      search_tokens = query.split(' ')
      results = KERBEROS_DIRECTORY_HASH[search_tokens[0]] || []

      1.upto(search_tokens.size - 1) do |i|
        results.select! { |ei| KERBEROS_DIRECTORY[ei][:common_name] =~ /\b#{search_tokens[i]}/i }
      end

      results.first(SEARCH_SUGGESTION_USER_LIMIT).map do |ei|
        e = KERBEROS_DIRECTORY[ei]
        {
          'address' => e[:kerberos],
          'name' => e[:common_name],
          'tokens' => e[:common_name].split(' ') + [e[:kerberos]],
          'type' => 'bitstation'
        }
      end
    end

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
      elsif u['type'] == 'coinbase'
        ['warning', 'This seems to be an user from Coinbase. ']
      elsif u['type'] == 'external'
        ['warning', 'This is an external address. ']
      end
    end
end

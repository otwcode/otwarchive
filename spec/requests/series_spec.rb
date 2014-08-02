require 'spec_helper'

describe "Series" do
  it 'response with 404 if page not found' do
    get :show, { series: 'pages', id: '12345' }
    expect(response.status).to eq(404)
  end
end

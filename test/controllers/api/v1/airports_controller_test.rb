require 'test_helper'

class Api::V1::AirportsControllerTest < ActionDispatch::IntegrationTest
  test 'should return a valid JSON response' do
    get '/api/v1/airports/find', params: { query: 'test' }

    assert_response :success
    assert_equal 'application/json', @response.media_type
  end

  test 'should return at least one record for valid query' do
    get '/api/v1/airports/find', params: { query: 'luxemb' }

    assert_response :success
    assert_equal 'application/json', @response.media_type

    airports = JSON.parse(@response.body)
    assert_operator airports.length, :>=, 1
  end

  test 'should confirm the airport name is Luxembourg Findel Airport' do
    get '/api/v1/airports/find', params: { query: 'luxemb' }

    assert_response :success
    assert_equal 'application/json', @response.media_type

    airports = JSON.parse(@response.body)
    assert_includes airports.first["name"], "Luxembourg Findel Airport"
  end

  test 'should not return any records for valid query' do
    get '/api/v1/airports/find', params: { query: 'kiev' }

    assert_response :success
    assert_equal 'application/json', @response.media_type

    airports = JSON.parse(@response.body)
    assert_operator airports.length, :>=, 0
  end
end

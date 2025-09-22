require 'rails_helper'

RSpec.describe "/customers", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end
  describe "GET /index" do
    it "renders a successful response" do
      Customer.create!(name: "João Silva", email: "joao@test.com", billing_day: 15, payment_method_type: "boleto")
      get customers_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      customer = Customer.create!(name: "João Silva", email: "joao@test.com", billing_day: 15, payment_method_type: "boleto")
      get customer_url(customer)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_customer_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      customer = Customer.create!(name: "João Silva", email: "joao@test.com", billing_day: 15, payment_method_type: "boleto")
      get edit_customer_url(customer)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) do
        { name: "João Silva", email: "joao@test.com", billing_day: 15, payment_method_type: "boleto" }
      end

      it "creates a new Customer" do
        expect {
          post customers_url, params: { customer: valid_attributes }
        }.to change(Customer, :count).by(1)
      end

      it "redirects to the created customer" do
        post customers_url, params: { customer: valid_attributes }
        expect(response).to redirect_to(customer_url(Customer.last))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        { name: "", email: "invalid", billing_day: 0 }
      end

      it "does not create a new Customer" do
        expect {
          post customers_url, params: { customer: invalid_attributes }
        }.to_not change(Customer, :count)
      end

      it "renders a response with 422 status" do
        post customers_url, params: { customer: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:customer) { Customer.create!(name: "João Silva", email: "joao@test.com", billing_day: 15, payment_method_type: "boleto") }
      let(:new_attributes) { { name: "João Santos" } }

      it "updates the requested customer" do
        patch customer_url(customer), params: { customer: new_attributes }
        customer.reload
        expect(customer.name).to eq("João Santos")
      end

      it "redirects to the customer" do
        patch customer_url(customer), params: { customer: new_attributes }
        customer.reload
        expect(response).to redirect_to(customer_url(customer))
      end
    end

    context "with invalid parameters" do
      let(:customer) { Customer.create!(name: "João Silva", email: "joao@test.com", billing_day: 15, payment_method_type: "boleto") }
      let(:invalid_attributes) { { name: "" } }

      it "renders a response with 422 status" do
        patch customer_url(customer), params: { customer: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:customer) { Customer.create!(name: "João Silva", email: "joao@test.com", billing_day: 15, payment_method_type: "boleto") }

    it "destroys the requested customer" do
      expect {
        delete customer_url(customer)
      }.to change(Customer, :count).by(-1)
    end

    it "redirects to the customers list" do
      delete customer_url(customer)
      expect(response).to redirect_to(customers_url)
    end
  end
end

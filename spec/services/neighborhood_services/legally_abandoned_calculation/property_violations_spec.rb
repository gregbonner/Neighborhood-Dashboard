require 'rails_helper'

RSpec.describe NeighborhoodServices::LegallyAbandonedCalculation::PropertyViolations do
  let(:neighborhood) { double(name: 'Neighborhood', address_source_uri: 'http://data.hax')}
  let(:dataset) { NeighborhoodServices::LegallyAbandonedCalculation::PropertyViolations.new(neighborhood) }
  let(:violations_query_object) { double }
  let(:property_violations_data) do
    [
      {
        'address' => 'Address 1',
        'mapping_location' => {
          'coordinates' => [-45,90]
        },
        'violation_description' => 'VACANT DATA'
      },
      {
        'address' => 'Address 1',
        'mapping_location' => {
          'coordinates' => [-45,90]
        },
        'violation_description' => 'BOARDED'
      },
      {
        'mapping_location' => {
          'coordinates' => [-45,90]
        },
        'violation_description' => 'VACANT DATA'
      },
      {
        'address' => '',
        'mapping_location' => {
          'coordinates' => [-45,90]
        },
        'violation_description' => 'VACANT DATA'
      }
    ]
  end

  let(:metadata) { {'viewLastModified' => 1433307658} }

  before do
    allow(KcmoDatasets::PropertyViolations).to receive(:new).and_return(violations_query_object)
    allow(violations_query_object).to receive(:vacant_registry_failure).and_return(violations_query_object)
    allow(violations_query_object).to receive(:boarded_longterm).and_return(violations_query_object)
    allow(violations_query_object).to receive(:request_data).and_return(property_violations_data)
    allow(violations_query_object).to receive(:metadata).and_return(metadata)
  end

  describe '#calculated_data' do
    let(:calculated_data) { dataset.calculated_data }

    it 'only adds in data with addresses that are present' do
      expect(calculated_data.length).to eq(1)
      expect(calculated_data['address 1']).to_not be_nil
    end

    it 'adds in the latitude and longitude from the dataset' do
      expect(calculated_data['address 1'][:longitude]).to eq(-45.0)
      expect(calculated_data['address 1'][:latitude]).to eq(90.0)
    end

    it 'attaches just one of the violations to the data hash' do
      expect(calculated_data['address 1'][:violation_description]).to eq('BOARDED')
    end
  end
end
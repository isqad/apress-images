# coding: utf-8

require 'spec_helper'

RSpec.describe Apress::Images::DeleteDanglingImages do
  describe '#call' do
    context 'when given conditions' do
      let(:service) do
        described_class.new(
          image_class: 'SubjectImage',
          conditions: ['updated_at < ? AND subject_id IS NULL', 1.minutes.ago],
          logger: Logger.new('/dev/null')
        )
      end

      before do
        Timecop.freeze(2.minutes.ago)

        create :subject_image, subject_id: 1
        create :subject_image, subject_id: nil

        Timecop.return
      end

      it { expect { service.call }.to change(SubjectImage, :count).from(2).to(1) }
    end

    context 'when limit reached' do
      let(:service) do
        described_class.new(
          image_class: 'SubjectImage',
          delete_limit: 2,
          batch_size: 1,
          logger: Logger.new('/dev/null')
        )
      end

      before do
        create_list :subject_image, 3, subject_id: nil
      end

      it do
        expect { service.call }.to change(SubjectImage, :count).from(3).to(1)
      end
    end
  end
end

require 'spec_helper'

describe WorksHelper, type: :helper do

  describe '#get_tweet_text' do

    before(:each) do
      @work = FactoryGirl.create(:work)
    end

    context "for an unrevealed work" do
      it "should say that it's a mystery work" do
        @work.in_unrevealed_collection = true
        expect(helper.get_tweet_text(@work)).to eq("Mystery Work")
      end
    end

    context "for an anonymous work" do
      it "should not include the author's name" do
        @work.in_anon_collection = true
        expect(helper.get_tweet_text(@work)).to match "Anonymous"
        expect(helper.get_tweet_text(@work)).not_to match "test pseud"
      end
    end

    context "for a multifandom work" do
      it "should not try to include all the fandoms" do
        @work.fandom_string = "Testing, Battlestar Galactica, Naruto"
        expect(helper.get_tweet_text(@work)).to match "Multifandom"
        expect(helper.get_tweet_text(@work)).not_to match "Battlestar"
      end
    end

    context "for a revealed, non-anon work with one fandom" do
      it "should include all info" do
        expect(helper.get_tweet_text(@work)).to eq("My title is long enough by #{@work.pseuds.first.name} - Testing")
      end
    end

  end

  describe '#all_coauthor_skins' do
    before do
      @allpseuds = Array.new(5) { |i| FactoryGirl.create(:pseud, name: "Pseud-#{i}") }
    end

    context 'no public work skins or private work skins' do
      it 'returns an empty array' do
        expect(helper.all_coauthor_skins).to be_empty
      end
    end

    context 'public work skins exist' do
      before do
        FactoryGirl.create(:public_work_skin, title: 'Z Public Skin')
        FactoryGirl.create(:public_work_skin, title: 'B Public Skin')
      end

      context 'no private work skins' do
        it 'returns public work skins, ordered by title' do
          expect(helper.all_coauthor_skins.pluck(:title)).to eq(['B Public Skin', 'Z Public Skin'])
        end
      end

      context 'private work skins exist' do
        before do
          FactoryGirl.create(:private_work_skin, title: 'A Private Skin', author: @allpseuds[3].user)
          FactoryGirl.create(:private_work_skin, title: 'M Private Skin', author: @allpseuds[0].user)
          FactoryGirl.create(:private_work_skin, title: 'Unowned Private Skin')
        end

        it 'returns public work skins and skins belonging to allpseuds, ordered by title' do
          expect(helper.all_coauthor_skins.pluck(:title)).to eq(['A Private Skin',
                                                                 'B Public Skin',
                                                                 'M Private Skin',
                                                                 'Z Public Skin'])
        end

        it 'does not return unassociated private work skins' do
          expect(helper.all_coauthor_skins.pluck(:title)).not_to include(['Unowned Private Skin'])
        end
      end
    end
  end
end

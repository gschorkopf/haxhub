require 'spec_helper'

describe GitAction do
  describe '.fetch_all_commits' do 
    let(:repo) do
      new_repo
    end

    let(:user) do 
      new_user
    end

    before do
      expect(repo).to be_valid
      expect(user).to be_valid
    end
    
    it 'should fetch upto 30 recent commits for a user and repo' do
      VCR.use_cassette('git_action_fetch_all') do
        commits = GitAction.fetch_all_commits(user,repo)
        expect( commits.count ).to eq 2
      end
    end

    it 'should add fetched commits to the table' do 
      VCR.use_cassette('git_action_fetch_all') do
        GitAction.fetch_all_commits(user,repo)
        expect( repo.git_actions.count ).to eq 2
      end
    end

    it 'should not add duplicate commits to the table' do 
      VCR.use_cassette('git_action_fetch_all') do
        GitAction.fetch_all_commits(user,repo)
        expect( repo.git_actions.count ).to eq 2
      end

      VCR.use_cassette('second_request_for_commits') do 
        expect {
          GitAction.fetch_all_commits(user,repo)
          }.to change(repo.git_actions, :count).by(0)
      end
    end

    it 'should create authors' do 
      VCR.use_cassette('git_action_fetch_all') do
        GitAction.fetch_all_commits(user,repo)
      end

      our_full_names = ['blair']
      our_git_names = ["blairtest"]

      target_author = repo.git_actions.first.author
      expect( target_author.class ).to eq Author
      expect( our_full_names ).to include target_author.full_name
      expect( our_git_names ).to include target_author.login
    end

  end
end

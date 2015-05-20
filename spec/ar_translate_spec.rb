RSpec.describe ArTranslate do
  let(:post) { Post.new }

  describe 'translating attribute values' do
    it 'keeps basic hstore functionality' do
      post.names = { 'de' => 'Hans' }
      post.names['en'] = 'John'

      post.save!

      expect(post.reload.names).to eq('de' => 'Hans', 'en' => 'John')
    end

    it 'has localized accessors for specified languages' do
      post.names = { 'de' => 'Hans', 'en' => 'John', 'es' => 'Bruno' }

      expect(post.name_de).to eq('Hans')
      expect(post.name_en).to eq('John')
      expect { post.name_es }.to raise_error(NoMethodError)

      post.name_de = 'Peter'
      expect(post.names['de']).to eq('Peter')

      expect do
        post.name_es = 'Mateo'
      end.to raise_error(NoMethodError)

      post.save!
      expect(post.reload.names).to eq('de' => 'Peter', 'en' => 'John', 'es' => 'Bruno')
    end

    it 'returns a list of accessor names' do
      expect(post.name_attributes).to eq(%i(name_de name_en))
    end

    it 'returns a list of accessor names at class level' do
      expect(Post.name_attributes).to eq(%i(name_de name_en))
    end

    it 'returns a list of languages' do
      expect(post.name_languages).to eq(%w(de en))
    end

    it 'returns a list of languages at class level' do
      expect(Post.name_languages).to eq(%w(de en))
    end
  end

  describe 'edge cases' do
    it 'accepts uppercase languages and symbols as languages' do
      Post.translates(:addresses, languages: ['DE', :en])
      expect(Post.address_languages).to eq(%w(de en))
    end
  end

  describe 'error cases' do
    it 'fails if the name is not pluralized' do
      expect do
        Post.translates(:author, languages: %w(de))
      end.to raise_error(ArTranslate::Error, /not pluralized/)
    end

    it 'fails for invalid languages' do
      expect do
        Post.translates(:addresses, languages: %w(en de_du pt))
      end.to raise_error(ArTranslate::Error, /invalid language/i)

      expect do
        Post.translates(:addresses, languages: %w(en de2 pt))
      end.to raise_error(ArTranslate::Error, /invalid language/i)

      expect do
        Post.translates(:addresses, languages: %w(en attributes pt))
      end.to raise_error(ArTranslate::Error, /invalid language/i)

      expect do
        Post.translates(:addresses, languages: %w(en languages pt))
      end.to raise_error(ArTranslate::Error, /invalid language/i)
    end

    it 'fails if there are no languages specified' do
      expect do
        Post.translates(:addresses)
      end.to raise_error(ArTranslate::Error, /no languages/i)

      expect do
        Post.translates(:addresses)
      end.to raise_error(ArTranslate::Error, /no languages/i)
    end

    it 'fails if the column type is not an hstore' do
      expect do
        Post.translates(:brokens, languages: %w(de))
        post.broken_de
      end.to raise_error(ArTranslate::Error, /not hstore/)
    end
  end
end

# Genetic algorithm to find a word. 
class WordGuesser
  # Alphabet of possible characters that the word can be made up of
  ALPHABET = ('a'..'z').to_a
  # Number of genomes in population
  GENOME_AMOUNTS = 20
  # Chance that a given gene will change
  MUTATION_CHANCE = 1 # percent

  # Method to run the genetic algorithm
  # It uses tournament selection to generate the next population of genomes
  def run(word="hello")
    @word = word.split('')
    seed_genome
    gens = 0
    while(true) do 
      gens += 1
      @new_genomes = []
      @tmp_new = []
      # Do the tournament selection, just take the most winning member of every 2.
      @genomes.each_slice(2){ |a,b| @tmp_new << (fitness(a)<=fitness(b) ? a : b) }
      # take the 2 most best candidates from the population and preserve them into the next round
      @new_genomes = @tmp_new.sort{ |a,b| fitness(a) <=> fitness(b) }[(0..1)]
      # Loop until we fill our new population with the target genomes.
      while(@new_genomes.length < GENOME_AMOUNTS)
        @new_genomes << crossover(@tmp_new[rand(@tmp_new.length-1)], @tmp_new[rand(@tmp_new.length-1)])
      end
      # Run mutation then sort in order of fitness.
      @new_genomes.collect!{|x| mutate(x) }.sort!{|a,b| fitness(a) <=> fitness(b) }
      # found the solution, end loop.
      break if @new_genomes.first == @word
      puts "#{@new_genomes.first} #{fitness(@new_genomes.first)}" if gens % 100 == 0
      # mix up the @new_genomes so the tournament selection has more chance of keeping the optimum upper half.
      @genomes = @new_genomes.sort { rand }
    end
    # I think this is right, maximum for brute forcing a 3 letter word being 26*26*26
    max = ALPHABET.length
    (@word.length-1).times{max = max*ALPHABET.length}
    puts "Brute force would find word in max #{max} attempts and average in #{max/2} attempts. This found in #{gens*GENOME_AMOUNTS} attempts"
    puts "Took #{gens} generations to find #{@word.join('')}"
  end

  # To attempt to stop the population hitting a local maximum, we randomise it up a bit.
  def mutate(a)
    a.collect{ |x| rand(100) < MUTATION_CHANCE ? ALPHABET[rand(ALPHABET.length)] : x }
  end

  # Generate GENOME_AMOUNTS random genomes of characters to seed the algorithm
  def seed_genome
    @genomes = []
    (1..GENOME_AMOUNTS).collect do |_| 
      @genomes << (1..@word.length).collect{ |_| ALPHABET[rand(ALPHABET.length-1)] }
    end
  end

  # choose a random point halfway through the genomes and switch them over to create children
  def crossover(a, b)
    crossover_point = rand(a.length-1)
    result = a.zip(b).collect.with_index{ |x, y| (y >= crossover_point ? x.last : x.first) }
    result
  end

  # calculate how close to optimal the genome is.
  def fitness(b)
    @word.zip(b).inject(0){ |x, y| x += (ALPHABET.index(y.first) - ALPHABET.index(y.last)).abs }
  end

end

puts "Enter word to guess: "
word = gets.downcase.gsub(/\n/, '')
WordGuesser.new.run(word)
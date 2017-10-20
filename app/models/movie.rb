class Movie < ActiveRecord::Base
    def self.allMovieRatings
        #['G', 'PG', 'PG-13', 'R', 'NC-17']
        Movie.distinct.pluck(:rating).sort
    end
end

class MoviesController < ApplicationController
  
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    #DEBUGGING USE ONLY!!
    session.clear if params[:session] == "clear"
    #fetch possible ratings from db and set safe checked default
    @all_ratings = Movie.allMovieRatings
    ratings_hash = Hash[*@all_ratings.map {|key| [key, 1]}.flatten]
    #set params if not already set or if empty
    @movies = Movie.all
    if params[:ratings]
      ratings_hash = params[:ratings]
      @checked_ratings = ratings_hash.keys
      @movies = @movies.where(rating: @checked_ratings)
      session[:ratings] = ratings_hash
    end
    if params[:sort_by]
      case params[:sort_by]
        when "title"
          @movies = @movies.order(:title)
          @title_hilite = "hilite"
          session[:sort_by] = "title"
        when "release_date"
          @movies = @movies.order(:release_date)
          @release_date_hilite = "hilite"
          session[:sort_by] = "release_date"
      end
    end
    #redirect to maintain RESTfulness
    if !params[:sort_by] || !params[:ratings]
      redirect_hash = (session[:ratings]) ? Hash[*session[:ratings].keys.map {|key| ["ratings[#{key}]", 1]}.flatten] : {ratings: ratings_hash}
      redirect_hash[:sort_by] = (session[:sort_by]) ? session[:sort_by] : "none"
      flash.keep
      redirect_to movies_path(redirect_hash) and return
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end

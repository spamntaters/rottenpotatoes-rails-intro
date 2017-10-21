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
    #fetch possible ratings from db and set safe checked default
    @all_ratings = Movie.allMovieRatings
    @checked_ratings ||= @all_ratings
    #set params if not already set or if empty
    params[:ratings] ||= session[:ratings]
    params[:sort_by] ||= session[:sort_by]
    @checked_ratings = params[:ratings].keys if params[:ratings]
    sort_by = params[:sort_by]
    @title_hilite = "hilite" if sort_by == "title"
    @release_date_hilite = "hilite" if sort_by == "release_date"
    @movies = Movie.all
    @movies = Movie.order(sort_by).where(rating: @checked_ratings)
    #save session
    session[:sort_by] = params[:sort_by]
    session[:ratings] = params[:ratings]
    #redirect to maintain RESTfulness
    flash.keep
    redirect_to movies_path({sort_by: params[:sort_by], ratings: params[:ratings]}) if params[:ratings] && params[:sort_by]

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

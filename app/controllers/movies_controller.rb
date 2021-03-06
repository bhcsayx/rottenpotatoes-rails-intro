class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

	if params[:ratings].nil? and params[:commit]
		session.clear()
	end
	@selected_ratings = (params[:ratings] || session[:selected_ratings] || {})
	@selected_sort = (params[:sort] || session[:selected_sort] || {})
	@all_ratings = Movie.all_ratings
	if @selected_ratings.size > 0
		@ratings_to_show = @selected_ratings.keys
	else
		@ratings_to_show = []
	end

	if @selected_sort != nil
		@movies = Movie.with_ratings(@ratings_to_show).order(@selected_sort)
	else
		@movies = Movie.with_ratings(@ratings_to_show)
	end
	
	#highlight selected sort keywords
	if @selected_sort == "title"
		@titleCSS = "hilite bg-warning"
		@releaseDateCSS = ""
	elsif @selected_sort == "release_date"
		@releaseDateCSS = "hilite bg-warning"
		@titleCSS = ""
	end

	session[:selected_ratings] = params[:ratings]
	session[:selected_sort] = params[:sort]

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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end

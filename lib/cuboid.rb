
class Cuboid

  attr_accessor :origin, :dimensions

  # @arguments [Integer,Integer,Integer,Integer,Integer,Integer] - x,y,z, l,h,w
  def initialize(*origin_and_dimensions)
    origin = (self.class.coordinates_to_hash self.class.dimension_names, origin_and_dimensions[0,3])
    dimensions = (self.class.coordinates_to_hash self.class.dimension_names, origin_and_dimensions[3,3])
    vertices = (self.class.vertices (self.class.origin_to_center origin, dimensions), dimensions)

    if (self.class.vertices_valid? vertices)
      self.origin = origin
      self.dimensions = dimensions
    else
      throw ArgumentError, "Invalid cuboid, one of the vertices is out of bound: #{ vertices.inspect }"
    end
  end

  # @arguments [Integer,Integer,Integer] - x,y,z
  # Moves object to the new origin
  # If movement was successful, returns true
  # Does not change state if update failed, returns false
  def move_to!(*origin)
    origin = (self.class.coordinates_to_hash self.class.dimension_names, origin)
    vertices = (self.class.vertices (self.class.origin_to_center origin, dimensions), dimensions)
    if (self.class.vertices_valid? vertices)
      self.origin = origin
      true
    else
      false
    end
  end

  # @arguments [Symbol,Symbol] 2d plane (Ex :x,:y)
  # @return Boolean
  # If rotation is successful, return true
  # Does not change state if update failed, returns false
  # Rotation is done over the origin, (So the box rolls over based on the plane specified)
  def rotate!(*plane)
    dimensions = (self.class.swap_dimension self.dimensions,*plane)
    origin = (self.class.next_origin self.origin, dimensions, plane)
    vertices = (self.class.vertices (self.class.origin_to_center origin, dimensions), dimensions)
    if (self.class.vertices_valid? vertices)
      self.dimensions = dimensions
      self.origin = origin
      true
    else
      false
    end
  end

  # Returns 8 vertices with first vertex as the smallest and last vertex the largest
  # @returns Array[ Hash ]
  def vertices
    (self.class.vertices (self.class.origin_to_center origin, dimensions), dimensions)
  end

  # @arguemnt [Cuboid]
  # @return true if the two cuboids intersect each other.  False otherwise.
  # Cuboids interect IFF for every dimension, there is an interesction
  def intersects?(other)
    self.class.dimension_names.all? do |dimension_name|
      (self.class.dimension_interesects? vertices.last, other.vertices.first, dimension_name)
    end
  end

  class << self

    def half(v)
      v / 2.0
    end

    def dimension_names
      [:x,:y,:z]
    end

    # @arguments [Hash,Hash,Hash]
    # @return [Hash]
    def build_vertex(center, dimensions, unit_vertex )
      dimension_names.reduce({}) do |a, dimension|
        a.merge(
          { dimension =>
            center[dimension] + (unit_vertex[dimension] * (half dimensions[dimension]))})
      end
    end

    # @arguemnt [Integer] - vertex number
    # @return [Hash] - vertex with all coordinates set to 1 or -1 based on input specified
    # Used internally to calculate vertices, but subtracting or adding half of dimension
    def build_unit_vertex(i)
      coordinates_to_hash dimension_names, [i / 4, i / 2, i].map{|v| v.even? ? -1 : 1}
    end

    def dimension_interesects?(max_vertex_a, min_vertex_b, dimension)
      max_vertex_a[dimension] >= min_vertex_b[dimension]
    end

    def coordinates_to_hash(names, values)
      (names.zip values).reduce({}){|a,v| (a.merge Hash[*v])}
    end

    def swap_dimension(dimensions, axis1, axis2)
      dimensions.merge({ axis1 => dimensions[axis2], axis2 => dimensions[axis1]} )
    end

    # Figures out what is the next vertex when rotation taking place
    def next_origin(origin, dimensions, plane)
      origin.merge({plane[1] => origin[plane[1]] - dimensions[plane[1]]})
    end

    def vertices(center, dimensions, v_number=7)
      if v_number < 0
        []
      else
        (vertices center, dimensions, v_number - 1).concat [
          (build_vertex center, dimensions, (build_unit_vertex v_number)) ]
      end
    end


    # @arguments [Hash,Hash] - center,dimensions
    # @return [Boolean]
    # Returns true if smallest vertex has positive values
    def vertices_valid?(vertices)
      vertices.first.values.min >= 0
    end

    # @arguements [Hash,Hash]
    # @return [Hash]
    # Figures out center of cuboid, simplifies formula
    def origin_to_center(origin, dimensions)
      dimension_names.reduce({}) do |all,dimension_name|
        all.merge({dimension_name => (origin[dimension_name] + (half dimensions[dimension_name]) )})
      end
    end
  end

end

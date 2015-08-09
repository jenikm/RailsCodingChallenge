require 'cuboid'

describe Cuboid do
  let(:subject_origin){[5,5,5]}
  let(:subject_dimensions){[10,10,10]}

  subject {Cuboid.new(*subject_origin.concat(subject_dimensions))}

  describe "move_to!" do
    it "changes the origin in the simple happy case" do
      expect(subject.move_to!(1,2,3)).to be true
    end

    it "It should return false if moving to invalid location" do
      expect(subject.move_to!(-1,2,3)).to be false
    end
  end

  describe "initialize" do
    it "Should throw error if invalid dimensions are specified" do
      (expect{Cuboid.new(-1,0,0,0,0,0)}).to raise_error ArgumentError
    end
  end

  describe "intersects?" do

    let(:next_to_subject) {Cuboid.new(16,16,16,10,10,10)}
    let(:intersects_subject_with_one_vertex_shared) {Cuboid.new(15,15,15,10,10,10)}
    let(:far_away_from_subject) {Cuboid.new(50,50,50,10,10,10)}

    it "intersects self" do
      (expect (subject.intersects? subject)).to be true
    end

    it "does not interesect cube that is far away" do
      (expect (subject.intersects? far_away_from_subject)).to be false
    end

    it "does not interesect cube that is next to other cube" do
      (expect (subject.intersects? next_to_subject)).to be false
    end

    it "Shares one vertex with subject and intersects" do
      (expect (subject.vertices & intersects_subject_with_one_vertex_shared.vertices).length).to be 1
      (expect subject.intersects? intersects_subject_with_one_vertex_shared).to be true
    end
  end

  describe "vertices" do

    let(:largest_vertex_dimensions) do
      subject_dimensions.zip(subject_origin).map(&lambda{|x,y| x+y})
    end

    it "Should have 8 vertices" do
      (expect subject.vertices.length).to eq 8
    end

    it "Largest vertex should have largest coordinates" do
      largest_vertex = subject.vertices.last
      (expect [largest_vertex[:x],largest_vertex[:y], largest_vertex[:z]]).to eq largest_vertex_dimensions
    end
  end

  describe "rotate!" do
    let(:rectangular){Cuboid.new(50,100,100,20,10,10)}
    let(:rotated_rectangular){ r=rectangular.clone;r.rotate!(:x,:y);r }
    let(:rectangular_on_the_floor_of_the_box){Cuboid.new(1,0,1,1,1,1)}

    it "Should swap x,y dimensions" do
      (expect rotated_rectangular.dimensions[:x]).to be rectangular.dimensions[:y]
      (expect rotated_rectangular.dimensions[:y]).to be rectangular.dimensions[:x]
      (expect rotated_rectangular.dimensions[:z]).to be rectangular.dimensions[:z]
      # Box slides down on rotation
      (expect rotated_rectangular.origin[:x]).to be 50
      (expect rotated_rectangular.origin[:y]).to be 80
      (expect rotated_rectangular.origin[:z]).to be 100
    end

    it "Rotate box down should not be possible" do
      (expect rectangular_on_the_floor_of_the_box.rotate!(:x,:y)).to be false
    end

    it "Rotate box right should be possible" do
      (expect rectangular_on_the_floor_of_the_box.rotate!(:y,:x)).to be true
    end

  end

end

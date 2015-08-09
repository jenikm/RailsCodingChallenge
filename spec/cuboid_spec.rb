require 'cuboid'

describe Cuboid do
  let(:subject_origin){[5,5,5]}
  let(:subject_dimensions){[10,10,10]}

  subject {Cuboid.new(*subject_origin.concat(subject_dimensions))}
  let(:rectangular){Cuboid.new(100,5,5,10,10,10)}

  describe "move_to!" do
    it "changes the origin in the simple happy case" do
      expect(subject.move_to!(1,2,3)).to be true
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

  describe "rotate" do
    let(:rotated_rectangular){ r=rectangular.clone;r.rotate!(:x,:y);r }

    it "Should swap x,y dimensions" do
      (expect rotated_rectangular.dimensions[:x]).to be rectangular.dimensions[:y]
      (expect rotated_rectangular.dimensions[:y]).to be rectangular.dimensions[:x]
      (expect rotated_rectangular.dimensions[:z]).to be rectangular.dimensions[:z]
    end

  end

end

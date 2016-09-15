# -*- coding: utf-8 -*-
require 'spec_helper'

include MyTools

describe MyTools::Affine do
	describe "param" do
	  let(:affine){ Affine.new }
	  let(:matrix_in_string){ "[9.492e+01,-1.875e+01,-1.986e+02;1.873e+01,9.428e+01,-3.378e+01;0.000e+00,0.000e+00,1.000e+00]" }
	  before do
	  	affine.matrix_in_string = matrix_in_string
	  end
	  it {expect(affine).not_to be_nil}
	  it {expect(affine.a).to be_eql(94.92)}
	  it {expect(affine.b).to be_eql(-18.75)}
	  it {expect(affine.c).to be_eql(-198.6)}
	  it {expect(affine.d).to be_eql(18.73)}
	  it {expect(affine.e).to be_eql(94.28)}
	  it {expect(affine.f).to be_eql(-33.78)}
	  #it {expect(affine.gain).to be_eql(1)}
  	end

  	describe ".from_points_pair" do
  		subject {Affine.from_points_pair(src, dest)}
  		let(:src){ [[-6000, 6000], [6000, 6000], [6000, -6000]] }
  		let(:dest){ [[137.36493594991393, -1293.4527317528443], [5120.083681717162, -303.56811032496336], [4129.142055888397, 4712.974776270574]] }
  		it {expect(subject).to be_instance_of(Affine)}
  	end

  	describe "#matrix_in_string" do
  		subject {affine.matrix_in_string}
  		let(:affine){Affine.from_points_pair(src, dest)}
  		let(:src){ [[-6000, 6000], [6000, 6000], [6000, -6000]] }
  		let(:dest){ [[137.36493594991393, -1293.4527317528443], [5120.083681717162, -303.56811032496336], [4129.142055888397, 4712.974776270574]] }
  		it {expect(subject).to be_instance_of(String)}
  	end

  	describe "#transform_points" do
  		subject {affine.transform_points(src_points, type)}
  		let(:affine){Affine.from_points_pair(src, dest)}
  		let(:src){ [[-6000, 6000], [6000, 6000], [6000, -6000]] }
  		let(:dest){ [[137.36493594991393, -1293.4527317528443], [5120.083681717162, -303.56811032496336], [4129.142055888397, 4712.974776270574]] }
  		let(:src_points){ src }
  		let(:type){ :normal }
  		it {expect(subject[0][0]).to be_within(0.1).of(dest[0][0])}
  		context "inverse" do
  			let(:src_points){ dest }
  			let(:type){ :inverse }
	  		it {expect(subject[0][0]).to be_within(0.1).of(src[0][0])}
  		end

  	end


end

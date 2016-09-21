require 'matrix'
require 'bigdecimal'
require 'bigdecimal/util'
require 'bigdecimal/ludcmp'
include LUSolve

module MyTools
  class Affine
  	  attr_accessor :matrix
  	  @hash_array_index = {'a' => 0, 'b' => 1}  

  	  def self.from_points_pair(src, dest)
  	  	uvs = src
  	  	xys = dest
  	  	xyuvs = []
  	  	uvs.each_with_index do |uv, idx|
  	  		xyuvs << xys[idx].dup.concat(uv.dup)
  	  	end

  	  	a = [[0,0,0],[0,0,0],[0,0,0]]
  	  	a[0][0] = uvs.inject(0){|s,uv| s + uv[0]**2 } # sum(u^2)
  	  	a[1][0] = a[0][1] = uvs.inject(0){|s,uv| s + (uv[0] * uv[1])} # sum(uv)
  	  	a[2][0] = a[0][2] = uvs.inject(0){|s,uv| s + uv[0] } # sum(u)
  	  	a[1][1] = uvs.inject(0){|s,uv| s + uv[1]**2} # sum(v^2)
  	  	a[1][2] = a[2][1] = uvs.inject(0){|s,uv| s + uv[1]} # sum(v)
  	  	a[2][2] = uvs.size

  	  	bx = [0,0,0]
  	  	bx[0] = xyuvs.inject(0){|s, xyuv| s + xyuv[0] * xyuv[2] } # sum(xu)
  	  	bx[1] = xyuvs.inject(0){|s, xyuv| s + xyuv[0] * xyuv[3] } # sum(xv)
  	  	bx[2] = xyuvs.inject(0){|s, xyuv| s + xyuv[0] } # sum(x)

  	  	by = [0,0,0]
  	  	by[0] = xyuvs.inject(0){|s, xyuv| s + xyuv[1] * xyuv[2] } # sum(yu)
  	  	by[1] = xyuvs.inject(0){|s, xyuv| s + xyuv[1] * xyuv[3] } # sum(yv)
  	  	by[2] = xyuvs.inject(0){|s, xyuv| s + xyuv[1] } # sum(y)

		ax = a.flatten.map(&:to_d)
		ay = a.flatten.map(&:to_d)

		bx = bx.map(&:to_d)
		by = by.map(&:to_d)

		zero = '0.0'.to_d
		one = '1.0'.to_d

		ps = ludecomp(ax, bx.size, zero, one)  # a が破壊的に変更される
		vabc = lusolve(ax, bx, ps, zero)

		ps = ludecomp(ay, by.size, zero, one)  # a が破壊的に変更される
		vdef = lusolve(ay, by, ps, zero)

	    m = Matrix[vabc.map(&:to_f),vdef.map(&:to_f),[0,0,1]]
	    # num_points = src.size
    	# mm = Matrix[src.map{|p| p[0]}, src.map{|p| p[1]}, Array.new(src.size, 1.0)]

  	  	ins = self.new
  	  	ins.matrix = m
  	  	ins
  	  end

  	  def initialize()
  	  	@matrix = nil
	  end

	  def matrix_in_string=(str)
	    str = str.gsub(/\[/,"").gsub(/\]/,"").gsub(/\;/,",").gsub(/\s+/,"")
	    tokens = str.split(',')
	    vals = tokens.map{|token| token.to_f}
	    vals.concat([0,0,1]) if vals.size == 6
	    if vals.size == 9
	      #@matrix_in_array = vals
		  @matrix = Matrix[vals[0..2],vals[3..5],vals[6..8]]
	    end
	  end

	  def matrix_in_string
	  	return unless matrix
	    array = matrix.to_a
	    str = ""
	    array.each do |row|
	      vals = Array.new
	      row.each do |val|
	        vals.push sprintf("%.3e",val) if val
	      end
	      str += vals.join(',')
	      str += ';'
	    end
	    "[#{str.sub(/\;$/,'')}]"	  	
	  end

	  def a
	  	@matrix[0,0]
	  end

	  def b
	  	@matrix[0,1]
	  end

	  def c
	  	@matrix[0,2]
	  end

	  def d
	  	@matrix[1,0]
	  end

	  def e
	  	@matrix[1,1]
	  end

	  def f
	  	@matrix[1,2]
	  end

	  def theta
	  	rad = (a - d)/(c + b)
	  	Math.atan(rad)
	  end

	  def gain
	  	a * Math.cos(theta) - b * Math.sin(theta)
	  end

	  def qx
	  	(a/gain - Math.cos(theta))/Math.sin(theta)
	  end

	  def qy
	  	(c/gain - Math.sin(theta))/Math.cos(theta)
	  end

	  def transform_length(l, type = :normal)
	    src_points = [[0,0],[l,0]]
	    dst_points = transform_points(src_points, type)
	    return Math::sqrt((dst_points[0][0] - dst_points[1][0]) ** 2 + (dst_points[0][1] - dst_points[1][1]) ** 2)
	  end


	  def transform_points(points, type = :normal)
	    case type
	    when :inverse
	      affine = matrix.inv
	    else
	      affine = matrix
	    end
	    num_points = points.size
	    src_points = Matrix[points.map{|p| p[0]}, points.map{|p| p[1]}, Array.new(points.size, 1.0)]
	    warped_points = (affine * src_points).to_a

	    xt = warped_points[0]
	    yt = warped_points[1]
	    dst_points = []
	    num_points.times do |i|
	      dst_points << [xt[i], yt[i]]
	    end
	    return dst_points
	  end
  end
end

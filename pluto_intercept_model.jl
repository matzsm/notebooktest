### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ c8d11586-b74d-44c1-92c8-98b9780e68d6
import Pkg; Pkg.add("Plots"); Pkg.add("PlutoUI")

# ╔═╡ 55188e98-5fb4-11ec-02fc-91b7448a5bb6
using Plots, InteractiveUtils, PlutoUI

# ╔═╡ 8a048995-7013-42d4-bca8-817b9d91efbd
md"""
# 2D Toy geometric intercept "defend the line" model

* Assumes interceptor launch simultaneous with threat divert to offset target

* Interceptor immediately diverts to new PIP following circular (constant acceleration) path

* Calculates required interceptor velocity and acceleration to reach PIP

* For 3D can assume initial vertical interceptor climb to PIP altitude, then simultaneous threat divert and interceptor turn to modified PIP
"""

# ╔═╡ 31bd552c-fed6-4bc5-b659-116edf2601d0
begin
	threatrange = @bind threat0 PlutoUI.Slider(0:1:200, default=150, show_value=true)
	targrange = @bind targ0 PlutoUI.Slider(0:1:50, default=30, show_value = true)
	ipfrac = @bind ip PlutoUI.Slider(0:100, default=50, show_value = true)

	md"""
	Threat range: $(threatrange) km
	
	Target range: $(targrange) km
	
	PIP fraction on threat path: $(ipfrac) %
	"""
end

# ╔═╡ 7ae0c24c-b799-402d-8df8-3c9f60d67ea8
α = atand(threat0/targ0);

# ╔═╡ 59f536d4-028a-42b4-b211-88040b115f41
begin
	threatfo = sqrt(threat0^2 + targ0^2)
	iprange = ip*threatfo/100.0
	irange = sqrt(targ0^2 + (threatfo - iprange)^2 -2.0*targ0*(threatfo- iprange)*cosd(α))
	yip = (threatfo - iprange)*sind(α)
	xip = targ0 - (threatfo - iprange)*cosd(α)
	forange = sqrt(xip^2 + yip^2)
	@show forange, irange
	β = atand(yip/xip)
	h = (yip/xip)*forange/2.0
	radius = sqrt(h^2 + (forange/2)^2)
end;

# ╔═╡ 3141d2b5-80ed-40ad-8f64-6a7d12af8b95
function circle_shape(x0, y0, radius)
	θ = LinRange(0, 2π, 500)
	x0 .+ radius*sin.(θ), y0 .+ radius*cos.(θ)
end;

# ╔═╡ c06ca36d-86cb-4b7c-b485-976e96d4f292
begin
	
	scatter((targ0,0), label="Target")
	scatter!((0,threat0), label="Initial threat position")
	scatter!((0,0), label="Interceptor LP")
	scatter!((xip,yip), label="PIP")
	plot!([0,0], [0,threat0], label = "LP to initial threat position")
	plot!([0,targ0] ,[0,0], label = "LP to target location")
	plot!([0,targ0], [threat0,0], xlims=(-5, 200), ylims=(-5,200), aspect_ratio = 1, framestyle = :axis, label = "Diverted threat"
	)

	#plot!([0,xip],[0,yip])
	plot!(circle_shape(radius, 0, radius), label = "Interceptor path to PIP", legend=:bottomright)
end

# ╔═╡ e1dc5cee-5ce9-4a2f-b040-0dfaea5618b6
begin
	arc_length = (180 - 2β)/180*π*radius
	md"""
	Interceptor path length: $arc_length km
	"""
end

# ╔═╡ 7f4b89b0-7dc5-4c76-80ad-08481bd39f79
begin
	threatvel = @bind v0 PlutoUI.Slider(0:0.1:10, default=1.5, show_value = true)

	md"""
	Threat velocity: $(threatvel) km/s
	"""
end

# ╔═╡ 492a9933-3e76-44ed-8e7e-9c2a1a28b869
begin
	t0 = iprange/v0
	md"""
	Threat time to PIP: $(t0) s
	"""
end

# ╔═╡ 0bc9285e-d87e-485e-9edf-029092f3a92f
begin
	v_int = arc_length/t0
	md"""
	Required interceptor velocity: $(v_int) km/s
	"""
end

# ╔═╡ e80f373f-2843-44dd-a78e-3309937b158e
begin
	a_int = v_int^2/radius*1000
	md"""
	Interceptor acceleration on circular path: $a_int m/s/s
	"""
end

# ╔═╡ c99413b0-d80d-4f08-99cb-3497a17f9468
begin
	g_int = a_int/9.81
	md"""
	Interceptor acceleration on circular path: $g_int g
	"""
end

# ╔═╡ Cell order:
# ╟─c8d11586-b74d-44c1-92c8-98b9780e68d6
# ╟─55188e98-5fb4-11ec-02fc-91b7448a5bb6
# ╟─8a048995-7013-42d4-bca8-817b9d91efbd
# ╟─31bd552c-fed6-4bc5-b659-116edf2601d0
# ╟─7ae0c24c-b799-402d-8df8-3c9f60d67ea8
# ╟─59f536d4-028a-42b4-b211-88040b115f41
# ╟─3141d2b5-80ed-40ad-8f64-6a7d12af8b95
# ╟─c06ca36d-86cb-4b7c-b485-976e96d4f292
# ╟─e1dc5cee-5ce9-4a2f-b040-0dfaea5618b6
# ╟─7f4b89b0-7dc5-4c76-80ad-08481bd39f79
# ╟─492a9933-3e76-44ed-8e7e-9c2a1a28b869
# ╟─0bc9285e-d87e-485e-9edf-029092f3a92f
# ╟─e80f373f-2843-44dd-a78e-3309937b158e
# ╟─c99413b0-d80d-4f08-99cb-3497a17f9468

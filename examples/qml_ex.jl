ENV["QSG_RENDER_LOOP"] = "basic"
using CxxWrap # for safe_cfunction
using QML
using GR

qmlfile = joinpath(dirname(Base.source_path()), "qml_ex.qml")

type Parameters
  nbins::Float64
end

parameters = Parameters(30)

# Called from QQuickPaintedItem::paint with the QPainter as an argument
function paint(p::QPainter)
  ENV["GKSwstype"] = 381
  ENV["GKSconid"] = split(repr(p.cpp_object), "@")[2]

  dev = device(p)
  plt = gcf()
  plt[:size] = (width(dev) * 0.72, height(dev) * 0.72)

  nbins = Int64(round(parameters.nbins))
  hexbin(randn(1000000), randn(1000000),
         nbins=nbins, xlim=(-5,5), ylim=(-5,5), title="nbins: $nbins")

  return
end

# Convert to cfunction, passing the painter as void*
paint_cfunction = safe_cfunction(paint, Void, (QPainter,))

# paint_cfunction becomes a context property
@qmlapp qmlfile paint_cfunction parameters
exec()

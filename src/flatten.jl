
#removes extra dimensions from each NeuronPoint. (for measure of distance this is equivalent of setting them all to the same value)
#keeps metadata of all points
function flatten_NeuronPoints(v, dims = 2)
    if length(v[1]) <= dims
        error("can't flatten, dim v = ", length(v[1]), ", target dim = ", dims)
    end

    prototype = meta(Point(zeros(dims)...), type = "Ep", layer = 1, comp = "s")
    w = fill(prototype, length(v))

    for i = 1:length(v)
        w[i] = meta(Point(v[i].main[1:dims]...); meta(v[i])...)
    end

    return w
end

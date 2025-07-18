class_name PreviewLight extends MeshInstance3D

@export var curves: Array[Curve3D]
@export var target: Target
@export var width: float = .2
@export var mat: Material


func update():
    if mesh != null:
        generate_mesh(mesh)
    else:
        mesh = generate_mesh()
    mesh.surface_set_material(0, mat)


func generate_mesh(p_mesh: ArrayMesh = ArrayMesh.new()) -> Mesh:
    var surface_array = []
    surface_array.resize(Mesh.ARRAY_MAX)
    var verts = PackedVector3Array()
    var uvs = PackedVector2Array()
    var indices = PackedInt32Array()
    
    if target.type == Target.Type.LINEAR:
        generate_linear_mesh(verts, uvs, indices)
    else:
        generate_spatial_mesh(verts, uvs, indices)
    
    surface_array[Mesh.ARRAY_VERTEX] = verts
    surface_array[Mesh.ARRAY_TEX_UV] = uvs
    surface_array[Mesh.ARRAY_INDEX] = indices
    p_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
    return p_mesh


func generate_linear_mesh(verts: PackedVector3Array, uvs: PackedVector2Array, indicies: PackedInt32Array):    
    var total_length: float = 0.0
    for curve in curves:
        total_length += curve.get_baked_length()
    
    var used_length: float = 0.0
    for curve in curves:
        var last_pos: Vector3 = Vector3.ZERO
        var llast_pos: Vector3 = Vector3.ZERO
        
        var i = 0
        var points = curve.get_baked_points()
        var up_vectors = curve.get_baked_up_vectors()
        for point in points:
            if i == 0:
                verts.append(point)
                verts.append(point + up_vectors[i]*width)
                var x = (float(i)/float(points.size()))*(float(curve.get_baked_length())/float(total_length))+used_length
                uvs.append(Vector2(x, 0.0))
                uvs.append(Vector2(x, 1.0))
                llast_pos = point
            elif i == 1:
                last_pos = point
            elif i == points.size() - 1:
                verts.append(point)
                verts.append(point + up_vectors[i]*width)
                var x = (float(curve.get_baked_length())/float(total_length))+used_length
                uvs.append(Vector2(x, 0.0))
                uvs.append(Vector2(x, 1.0))
                for index in verts.size()/2-1:
                    indicies.append(index)
                    indicies.append(index+1)
                    indicies.append(index+3)
                    
                    indicies.append(index+2)
                    indicies.append(index)
                    indicies.append(index+3)
            else:
                var last_change = last_pos.direction_to(llast_pos)
                var change = point.direction_to(last_pos)
                if last_change != change:
                    verts.append(point)
                    verts.append(point + up_vectors[i]*width)
                    var x = (float(i)/float(points.size()))*(float(curve.get_baked_length())/float(total_length))+used_length
                    uvs.append(Vector2(x, 0.0))
                    uvs.append(Vector2(x, 1.0))
                
                llast_pos = last_pos
                last_pos = point
                
            i+=1
        used_length += curve.get_baked_length()


func generate_spatial_mesh(verts: PackedVector3Array, uvs: PackedVector2Array, indicies: PackedInt32Array):
    var index = 0
    for point in target.points:
        verts.append(point)
        verts.append(point + Vector3(width, 0, 0))
        verts.append(point + Vector3(width/2, 0, width))
        verts.append(point + Vector3(width/2, width, width/2))
        indicies.append(index)
        indicies.append(index+1)
        indicies.append(index+2)
        
        indicies.append(index)
        indicies.append(index+3)
        indicies.append(index+1)
        
        indicies.append(index+1)
        indicies.append(index+3)
        indicies.append(index+2)
        
        indicies.append(index+2)
        indicies.append(index+3)
        indicies.append(index)
        
        for i in 4:
            uvs.append(Vector2(float(index)/float(target.points.size()), 0.0))
        index+=4

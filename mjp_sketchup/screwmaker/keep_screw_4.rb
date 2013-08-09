require 'sketchup.rb'

module MJP_Threads4

  unless file_loaded?( __FILE__ )
  
    menu=UI.menu( 'Plugins' )
    menu.add_item( 'Threadmaker4' ) { self.Threads4}
  end 
  
def self.Threads4 


model = Sketchup.active_model
entities = model.entities
selection = model.selection
view = model.active_view
layers = model.layers
definitions = model.definitions
activelayer = model.active_layer
layer = model.active_layer=layers[0]


r1=1          # internal radius
tdepth=0.05   # depth of tooth
r2=r1+tdepth
blength=1.0   # centerline length of spiral
tperinch=5.0  # teeth per inch
theight=1/tperinch  # distance between teeth

angincr=10*3.141592/180.0  #angle of increment set at 10 degees
prompts = ["Internal Diam", "External Diam", "Pitch","Length","percent cut","gap"]
defaults = ["1.0", "1.2","0.1","2","50","0.01"]

input = UI.inputbox prompts, defaults, "Sketchy Threads"
din=input[0].to_f
doout=input[1].to_f
pitch=input[2].to_f
blength=input[3].to_f
tcutper=input[4].to_f/100.0
gap=input[5].to_f
r1=din/2.0
r2=doout/2.0
tperinch=1.0/pitch
incrperrev=pitch/36.0  #this one is hard coded to 36 should change
t=Geom::Transformation.new([0,0,0],[0,0,1],10*3.1415/180)
t2=Geom::Vector3d.new(0,0,incrperrev)


#the next section defines the vertex points of one 
#finite element of the spiral

pts = []
opts=[]
vs=[]

pts[0] = [r1, 0, 0]
pts[1] = [r2, 0, pitch/2.0]
pts[2] = [r1, 0, pitch]
pts[3] = Geom::Point3d.linear_combination(1-tcutper,pts[0],tcutper,pts[1])
pts[4] = Geom::Point3d.linear_combination(1-tcutper,pts[2],tcutper,pts[1])
pts[5] = [Math.cos(angincr)*r1,Math.sin(angincr)*r1,incrperrev]
pts[6] = [Math.cos(angincr)*r2,Math.sin(angincr)*r2,incrperrev+(pitch/2.0)]
pts[7] = [Math.cos(angincr)*r1,Math.sin(angincr)*r1,incrperrev+pitch]
pts[8] = Geom::Point3d.linear_combination(1-tcutper,pts[5],tcutper,pts[6])
pts[9] = Geom::Point3d.linear_combination(1-tcutper,pts[7],tcutper,pts[6])
for i in 0..9 do
  vs[i] = Geom::Vector3d.new(pts[i][0],pts[i][1],0).normalize!
  vs[i].length=gap
  opts[i]=pts[i].offset(vs[i])
end
opts[10]=Geom::Point3d.new(opts[1].x,opts[1].y,opts[0].z)
opts[11]=opts[10].transform(t)
opts[11]=opts[11].offset(t2)
ovec=opts[1].vector_to(opts[10])
opts[10].offset!(ovec)
opts[11].offset!(ovec)

 # Add a new group to the entities in the model
 group = entities.add_group

 # Get the entities within the group
 entities2 = group.entities

 # Add a face to within the group

newlayer = layers.add "screw"
activelayer = model.active_layer = layers[1]
layer = model.active_layer
 
 
face = entities2.add_face(pts[0],pts[3],pts[4],pts[2])
face = entities2.add_face(pts[0+5],pts[2+5],pts[4+5],pts[3+5])
face = entities2.add_face(pts[2],pts[5+4],pts[5+2])
face = entities2.add_face(pts[2],pts[4],pts[5+4])

face = entities2.add_face(pts[0],pts[2],pts[5+2],pts[5+0])
face = entities2.add_face(pts[4],pts[3],pts[5+3],pts[5+4])
face = entities2.add_face(pts[0],pts[5+3],pts[3])
face = entities2.add_face(pts[0],pts[5],pts[5+3])

#the next statement defines a component piece
#assuming that its origin is [0,0,0]


a=group.to_component

#brings in the last component in the definitions
#and then treating it as the last entity transforms
#it to the proper place.
 
for i in 1..tperinch*blength*36-1 do
  entities.add_instance(definitions[-1],[0,0,0])
  tran3=Geom::Transformation.new([0,0,0],[0,0,1],i*3.14159/18.0)
  tran4=Geom::Transformation.new([0,0,incrperrev*i])
  entities.transform_entities(tran3,entities[-1])
  entities.transform_entities(tran4,entities[-1])
  #}
end

newlayer = layers.add "bolt"
activelayer = model.active_layer = layers[2]
layer = model.active_layer

 # Add a new group to the entities in the model
 group = entities.add_group

 # Get the entities within the group
 entities2 = group.entities

face = entities2.add_face(opts[0],opts[10],opts[1])
face = entities2.add_face(opts[5+0],opts[5+1],opts[11])
face = entities2.add_face(opts[10],opts[11],opts[6],opts[1])
face = entities2.add_face(opts[0],opts[1],opts[6],opts[5])
face = entities2.add_face(opts[0],opts[5],opts[11],opts[10])
a=group.to_component

#face = entities.add_face(opts[0],opts[3],opts[4],opts[2])
#face = entities.add_face(opts[0+5],opts[2+5],opts[4+5],opts[3+5])
#face = entities.add_face(opts[2],opts[5+4],opts[5+2])
#face = entities.add_face(opts[2],opts[4],opts[5+4])

#face = entities.add_face(opts[0],opts[2],opts[5+2],opts[5+0])
#face = entities.add_face(opts[4],opts[3],opts[5+3],opts[5+4])
#face = entities.add_face(opts[0],opts[5+3],opts[3])
#face = entities.add_face(opts[0],opts[5],opts[5+3])



for i in 1..tperinch*blength*36-1 do
  entities.add_instance(definitions[-1],[0,0,0])
  tran3=Geom::Transformation.new([0,0,0],[0,0,1],i*3.14159/18.0)
  tran4=Geom::Transformation.new([0,0,incrperrev*i])
  entities.transform_entities(tran3,entities[-1])
  entities.transform_entities(tran4,entities[-1])
  #}
end

end

end
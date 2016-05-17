project.theme <-function(base_size = 12, base_family = "Helvetica"){
  color.plot.area = "white"
  color.background = "white"
  color.grid.major = "#2c3e50"
  color.axis.text = "#2c3e50"
  color.axis.title = "#2c3e50"
  color.title = "#2c3e50"
  
  
  
  theme_bw() +
    theme(panel.background=element_rect(fill=color.plot.area, color=color.plot.area)) +
    theme(plot.background=element_rect(fill=color.background, color=color.background)) +
    theme(panel.border=element_rect(color="#2c3e50", size = 0.75)) +
    theme(panel.grid.major=element_line(color=color.grid.major,size=.25, 
                                        linetype = "longdash")) + 
    theme(axis.line = element_line(color=color.grid.major, size = .5))+
    theme(panel.grid.minor=element_blank()) +
    theme(plot.title=element_text(color=color.title, size=10)) +
    theme(axis.text.x=element_text(size=11,color=color.axis.text)) +
    theme(axis.text.y=element_text(size=11,color=color.axis.text)) +
    theme(axis.title.x=element_text(size=14,color=color.axis.title, face = "bold")) +
    theme(axis.title.y=element_text(size=14,color=color.axis.title, face = "bold")) 
}

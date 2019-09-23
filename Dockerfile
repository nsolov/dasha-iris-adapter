FROM store/intersystems/iris:2019.2.0.107.0-community

COPY src /mysrc

RUN iris start iris \
  && printf '_SYSTEM\nSYS\nnewpass\nnewpass\ndo $system.OBJ.Load("/mysrc/Installer.cls", "ck")\n \
  \nset vars("SRCDIR")="/mysrc"\ndo ##class(Dasha.Installer).setup(.vars)\nhalt' | iris terminal IRIS -U %SYS \
  && iris stop iris quietly


##### Build defaults #####
MAKE = make
CXX = g++

TARGET_SO =         lua_bigint.so
TARGET_A  =         liblua_bigint.a
CFLAGS =            -std=c++11 -g3 -Wall -pedantic -fno-inline
# CFLAGS =            -std=c++11 -O2 -Wall -pedantic #-DNDEBUG

SHAREDDIR = .sharedlib
STATICDIR = .staticlib

# AR= ar rcu # ar: `u' modifier ignored since `D' is the default (see `U')

AR= ar rc
RANLIB= ranlib

OBJS = lbigint.o

SHAREDOBJS = $(addprefix $(SHAREDDIR)/,$(OBJS))
STATICOBJS = $(addprefix $(STATICDIR)/,$(OBJS))

DEPS := $(SHAREDOBJS + STATICOBJS:.o=.d)

#The dash at the start of '-include' tells Make to continue when the .d file doesn't exist (e.g. on first compilation)
-include $(DEPS)

.PHONY: all clean test staticlib sharedlib

$(SHAREDDIR)/%.o: %.cpp
	@[ ! -d $(SHAREDDIR) ] & mkdir -p $(SHAREDDIR)
	$(CXX) -c $(CFLAGS) -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -o $@ $<

$(STATICDIR)/%.o: %.cpp
	@[ ! -d $(STATICDIR) ] & mkdir -p $(STATICDIR)
	$(CXX) -c $(CFLAGS) -MMD -MP -MF"$(@:%.o=%.d)" -o $@ $<

all: $(TARGET_SO) $(TARGET_A)

staticlib: $(TARGET_A)
sharedlib: $(TARGET_SO)


# -Wl,-E
# When creating a dynamically linked executable, using the -E option or the
# --export-dynamic option causes the linker to add all symbols to the dynamic
# symbol table. The dynamic symbol table is the set of symbols which are visible
# from dynamic objects at run time
# -Wl,--whole-archive /usr/local/lib/libflatbuffers.a -Wl,--no-whole-archive
$(TARGET_SO): $(SHAREDOBJS)
	$(CXX) $(LDFLAGS) -shared -o $@ $(SHAREDOBJS) $(LUA_FLATBUFFERS_DEPS)

$(TARGET_A): $(STATICOBJS)
	$(AR) $@ $(STATICOBJS)
	$(RANLIB) $@

test:
	g++ -std=c++11 -Wall -g -o cpp_perf cpp_perf.cpp
	./cpp_perf

clean:
	rm -f -R $(SHAREDDIR) $(STATICDIR) $(TARGET_SO) $(TARGET_A)
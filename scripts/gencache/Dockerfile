# Dockerfile for building EasyRPG tools

FROM danger89/cmake:bookworm-cppcheck-2.19.0

# Install liblcf dependencies
RUN apt update && apt install -y libinih-dev libicu-dev libexpat1-dev nlohmann-json3-dev

# Build liblcf
RUN wget https://easyrpg.org/downloads/player/0.8.1/liblcf-0.8.1.tar.gz && tar xzf liblcf-0.8.1.tar.gz && cd liblcf-0.8.1 && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build build && cmake --build build --target install

# Build EasyRPG tools
RUN wget https://github.com/EasyRPG/Tools/archive/9aa8e8adad999cf972735ce12d184406495d8dfb.tar.gz && tar xzf 9aa8e8adad999cf972735ce12d184406495d8dfb.tar.gz && cd Tools-9aa8e8adad999cf972735ce12d184406495d8dfb && cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DDISABLE_LMU2PNG=ON -DDISABLE_PNG2XYZ=ON -DDISABLE_XYZ2PNG=ON -DDISABLE_XYZCRUSH=ON -DDISABLE_LCFTRANS=ON -DDISABLE_LCFVIZ=ON && cmake --build build && cmake --build build --target install

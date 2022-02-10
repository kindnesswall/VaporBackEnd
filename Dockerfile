
#Check https://hub.docker.com/_/swift
#FROM swift:5.5.2-focal
FROM swift:5.4.2

WORKDIR /app

COPY ./Package.* /app/
RUN swift package resolve

COPY . /app
#RUN swift build -c release
RUN swift build

# Copy main executable to the WORKDIR
#RUN cp "$(swift build --package-path /app -c release --show-bin-path)/Run" /app
RUN cp "$(swift build --package-path /app --show-bin-path)/Run" /app

ENTRYPOINT ["./Run"]
CMD ["serve", "--auto-migrate"] 

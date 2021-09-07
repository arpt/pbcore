# Build Process

## Buildpacks.io 

https://buildpacks.io/docs/tools/pack/


## Install 

go get -u github.com/buildpacks/pack    


## GitHub Actions

```yaml 

      - name: Setup BuildPacks
        uses: buildpacks/github-actions/setup-pack@v4.1.1

```


```yaml 

  build:
    name: Build Go Binary
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Setup Go
        uses: actions/setup-go@v2
        with:
          go-version: 1.16

      - name: Build Go Binary
        run: go build -v ./...


```


## Deployments

## Cloud Run 

### Good To Know  
When deploying to Cloud Run ensure Max Instances is set above 3.  Even if you calculate the total load will be below the Concurrent Rate limit and you wish to avoid extra costs due and the services aren't SL1    This will ensure services are capable to handling internal GCP issues that result in gcp backing off spinning up necessary resources when internal gcp lb/service routing issues occur. 


 
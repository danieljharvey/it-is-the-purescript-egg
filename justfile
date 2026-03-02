build:
    cd rust && wasm-pack build --target web --out-dir ../public/pkg

test:
    cd rust && cargo test

serve:
    npx serve public

dev: build serve

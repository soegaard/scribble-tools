export default {
  build: {
    sourcemap: true,
    rollupOptions: {
      output: {
        chunkFileNames: "chunks/[name]-[hash].js"
      }
    }
  }
};

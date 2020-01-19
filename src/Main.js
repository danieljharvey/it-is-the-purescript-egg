function getWindowLevelUrl() {
  if (typeof window === 'undefined') {
    return ''
  }
  const urlParams = new URLSearchParams(window.location.search)
  if (urlParams.has('url')) {
    return urlParams.get('url')
  }
  return ''
}

exports.getWindowLevelUrl = getWindowLevelUrl 

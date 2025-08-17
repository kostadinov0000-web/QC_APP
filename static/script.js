// Global variables for zoom functionality
let currentZoom = 1.0;
let currentPdfSrc = null;

function showToast(message, status) {
    const toast = document.createElement('div');
    toast.className = `fixed bottom-4 right-4 p-4 rounded shadow-lg text-white ${status === 'success' ? 'bg-green-500' : 'bg-red-500'}`;
    toast.textContent = message;
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 3000);
}

function showDimensionsModal(productId, productName) {
    document.getElementById('productId').value = productId;
    document.getElementById('modalProductName').innerText = `Dimensions for ${productName}`;
    document.getElementById('dimensionsModal').classList.remove('hidden');
    loadDimensions(productId);
}

function closeDimensionsModal() {
    document.getElementById('dimensionsModal').classList.add('hidden');
    document.getElementById('addDimensionForm').reset();
    document.getElementById('dimensionsTable').querySelector('tbody').innerHTML = '';
}

function loadDimensions(productId) {
    fetch(`/get_dimensions/${productId}`)
        .then(response => response.json())
        .then(dimensions => {
            const tbody = document.getElementById('dimensionsTable').querySelector('tbody');
            tbody.innerHTML = '';
            dimensions.forEach(dim => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td class="p-2 border">${dim.id}</td>
                    <td class="p-2 border">${dim.dimension_name}</td>
                    <td class="p-2 border">${dim.nominal_value}</td>
                    <td class="p-2 border">-${dim.tolerance_minus}</td>
                    <td class="p-2 border">+${dim.tolerance_plus}</td>
                    <td class="p-2 border">
                        <button onclick="deleteDimension(${dim.id}, ${productId})" class="bg-red-500 text-white p-1 rounded hover:bg-red-600">Delete</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        });
}

function deleteDimension(dimensionId, productId) {
    if (confirm('Delete this dimension?')) {
        fetch('/delete_dimension', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `dimension_id=${dimensionId}`
        })
        .then(response => response.json())
        .then(data => {
            showToast(data.message, data.status);
            if (data.status === 'success') loadDimensions(productId);
        });
    }
}

function loadDimensionsForMeasurements(productId) {
    if (!productId) {
        document.getElementById('measurementsTable').querySelector('tbody').innerHTML = '';
        return;
    }
    fetch(`/get_dimensions/${productId}`)
        .then(response => response.json())
        .then(dimensions => {
            const tbody = document.getElementById('measurementsTable').querySelector('tbody');
            tbody.innerHTML = '';
            dimensions.forEach(dim => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td class="p-2 border">${dim.dimension_name}</td>
                    <td class="p-2 border">${dim.nominal_value}</td>
                    <td class="p-2 border">-${dim.tolerance_minus}/+${dim.tolerance_plus}</td>
                    <td class="p-2 border">
                        <input type="number" step="any" name="measured_value_${dim.id}" class="w-full p-2 border rounded">
                    </td>
                `;
                tbody.appendChild(row);
            });
        });
}

function loadProductDrawing(productId) {
    const drawingContainer = document.getElementById('drawingContainer');
    if (!drawingContainer) return; // Not on a page that uses drawings

    const drawing1Container = document.getElementById('drawing1Container');
    const drawing2Container = document.getElementById('drawing2Container');
    const thumbnail1 = document.getElementById('drawingThumbnail1');
    const thumbnail2 = document.getElementById('drawingThumbnail2');
    const noDrawingMessage = document.getElementById('noDrawingMessage');
    const pdfViewer = document.getElementById('pdfViewer');

    if (!productId) {
        drawingContainer.classList.add('hidden');
        if (pdfViewer) pdfViewer.src = '';
        return;
    }

    fetch(`/get_product/${productId}`)
        .then(r => r.json())
        .then(data => {
            if (data.error) {
                drawingContainer.classList.add('hidden');
                if (pdfViewer) pdfViewer.src = '';
                return;
            }

            let hasDrawings = false;

            // First drawing
            if (data.drawing_path) {
                if (thumbnail1) {
                    thumbnail1.src = '/static/images/pdf-icon.png';
                    thumbnail1.onclick = () => {
                        if (pdfViewer) pdfViewer.src = `/${data.drawing_path}`;
                        if (typeof openDrawingModal === 'function') openDrawingModal(1);
                    };
                }
                if (drawing1Container) drawing1Container.classList.remove('hidden');
                hasDrawings = true;
            } else {
                if (drawing1Container) drawing1Container.classList.add('hidden');
            }

            // Second drawing
            if (data.drawing_path_2) {
                if (thumbnail2) {
                    thumbnail2.src = '/static/images/pdf-icon.png';
                    thumbnail2.onclick = () => {
                        if (pdfViewer) pdfViewer.src = `/${data.drawing_path_2}`;
                        if (typeof openDrawingModal === 'function') openDrawingModal(2);
                    };
                }
                if (drawing2Container) drawing2Container.classList.remove('hidden');
                hasDrawings = true;
            } else {
                if (drawing2Container) drawing2Container.classList.add('hidden');
            }

            if (hasDrawings) {
                drawingContainer.classList.remove('hidden');
                if (noDrawingMessage) noDrawingMessage.classList.add('hidden');
            } else {
                drawingContainer.classList.add('hidden');
                if (noDrawingMessage) noDrawingMessage.classList.remove('hidden');
            }
        })
        .catch(err => {
            console.error('Error fetching product for drawings', err);
            drawingContainer.classList.add('hidden');
            if (pdfViewer) pdfViewer.src = '';
        });
}

function openDrawingModal() {
    const modal = document.getElementById('drawingModal');
    modal.classList.remove('hidden');
    
    // Add keyboard event listeners for zoom shortcuts
    document.addEventListener('keydown', handleKeyDown);
}

function closeDrawingModal(event) {
    if (event.target.id === 'drawingModal' || event.target.tagName === 'BUTTON') {
        const modal = document.getElementById('drawingModal');
        modal.classList.add('hidden');
        
        // Remove keyboard event listeners
        document.removeEventListener('keydown', handleKeyDown);
    }
}

function handleKeyDown(event) {
    // Only handle keys when modal is open
    if (document.getElementById('drawingModal').classList.contains('hidden')) return;
    
    switch(event.key) {
        case '+':
        case '=':
            event.preventDefault();
            zoomIn();
            break;
        case '-':
            event.preventDefault();
            zoomOut();
            break;
        case '0':
            event.preventDefault();
            zoomReset();
            break;
        case 'f':
        case 'F':
            event.preventDefault();
            zoomFit();
            break;
        case 'l':
        case 'L':
            event.preventDefault();
            setLargeSize();
            break;
        case 'F11':
            event.preventDefault();
            toggleFullscreen();
            break;
        case 'Escape':
            closeDrawingModal({target: {id: 'drawingModal'}});
            break;
    }
}

function updateZoomDisplay() {
    const zoomDisplay = document.getElementById('zoomDisplay');
    if (zoomDisplay) {
        zoomDisplay.textContent = Math.round(currentZoom * 100) + '%';
    }
}

function zoomIn(event) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }
    currentZoom = Math.min(currentZoom * 1.2, 5.0); // Max 500% zoom
    updateZoomDisplay();
    const iframe = document.getElementById('pdfViewer');
    if (iframe) {
        iframe.style.transform = `scale(${currentZoom})`;
        iframe.style.transformOrigin = 'top left';
        // Remove width/height scaling for scrollable zoom
        iframe.style.width = '100%';
        iframe.style.height = '100%';
    }
}

function zoomOut(event) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }
    currentZoom = Math.max(currentZoom / 1.2, 0.1); // Min 10% zoom
    updateZoomDisplay();
    const iframe = document.getElementById('pdfViewer');
    if (iframe) {
        iframe.style.transform = `scale(${currentZoom})`;
        iframe.style.transformOrigin = 'top left';
        // Remove width/height scaling for scrollable zoom
        iframe.style.width = '100%';
        iframe.style.height = '100%';
    }
}

function zoomFit(event) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }
    
    // Auto-fit the PDF to the current container size
    autoFitPDF();
}

function zoomReset(event) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }
    
    currentZoom = 1.0;
    updateZoomDisplay();
    
    // Reset iframe transform
    const iframe = document.getElementById('pdfViewer');
    if (iframe) {
        iframe.style.transform = 'scale(1)';
        iframe.style.transformOrigin = 'top left';
    }
}

function toggleFullscreen(event) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }
    
    const modal = document.getElementById('drawingModal');
    const modalContent = modal.querySelector('.bg-white');
    const fullscreenBtn = document.getElementById('fullscreenBtn');
    
    if (!modalContent || !fullscreenBtn) return;
    
    if (modalContent.classList.contains('fullscreen')) {
        // Exit fullscreen
        modalContent.classList.remove('fullscreen');
        modalContent.style.width = '1400px';
        modalContent.style.height = '1000px';
        fullscreenBtn.textContent = '⛶';
        fullscreenBtn.title = 'Toggle Fullscreen';
    } else {
        // Enter fullscreen
        modalContent.classList.add('fullscreen');
        modalContent.style.width = '98vw';
        modalContent.style.height = '98vh';
        fullscreenBtn.textContent = '⛶';
        fullscreenBtn.title = 'Exit Fullscreen';
    }
}

function autoFitPDF() {
    const container = document.querySelector('#drawingModal .border-2');
    if (!container) return;
    const containerWidth = container.clientWidth - 20;
    const containerHeight = container.clientHeight - 20;
    const iframe = document.getElementById('pdfViewer');
    if (iframe) {
        const defaultScale = Math.min(containerWidth / 800, containerHeight / 600, 1.0);
        currentZoom = defaultScale;
        updateZoomDisplay();
        iframe.style.transform = `scale(${defaultScale})`;
        iframe.style.transformOrigin = 'top left';
        // Remove width/height scaling for scrollable zoom
        iframe.style.width = '100%';
        iframe.style.height = '100%';
    }
}

function setLargeSize(event) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }
    
    const modal = document.getElementById('drawingModal');
    const modalContent = modal.querySelector('.bg-white');
    
    if (!modalContent) return;
    
    // Remove fullscreen class if active
    modalContent.classList.remove('fullscreen');
    
    // Set to large size (1600x1200)
    modalContent.style.width = '1600px';
    modalContent.style.height = '1200px';
    
    // Update the iframe container height
    const iframeContainer = modalContent.querySelector('.border-2');
    if (iframeContainer) {
        iframeContainer.style.height = '800px'; // Larger height for large mode
    }
    
    // Auto-fit the PDF to the new larger size
    setTimeout(() => {
        autoFitPDF();
    }, 100);
}

function setDefaultSize(event) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }
    
    const modal = document.getElementById('drawingModal');
    const modalContent = modal.querySelector('.bg-white');
    
    if (!modalContent) return;
    
    // Remove fullscreen class if active
    modalContent.classList.remove('fullscreen');
    
    // Reset to default size
    modalContent.style.width = '';
    modalContent.style.height = '';
    
    // Reset the iframe container height
    const iframeContainer = modalContent.querySelector('.border-2');
    if (iframeContainer) {
        iframeContainer.style.height = '600px'; // Default height
    }
    
    // Auto-fit the PDF to the new size
    setTimeout(() => {
        autoFitPDF();
    }, 100);
}

function downloadPDF(event) {
    if (event) {
        event.preventDefault();
        event.stopPropagation();
    }
    
    if (currentPdfSrc) {
        window.open(currentPdfSrc, '_blank');
    }
}

function showDrawingModal(drawingPath) {
    const modal = document.getElementById('drawingModal');
    const iframe = document.getElementById('pdfViewer');
    const downloadLink = document.getElementById('downloadLink');
    
    if (iframe && downloadLink) {
        // Set the PDF source
        iframe.src = `/view_pdf/${encodeURIComponent(drawingPath)}`;
        
        // Set download link
        downloadLink.href = `/view_pdf/${encodeURIComponent(drawingPath)}`;
        downloadLink.download = drawingPath.split('/').pop() || 'drawing.pdf';
        
        // Reset zoom
        currentZoom = 1.0;
        updateZoomDisplay();
        
        // Reset iframe transform
        iframe.style.transform = 'scale(1)';
        iframe.style.transformOrigin = 'top left';
        
        // Show modal
        modal.classList.remove('hidden');
        
        // Auto-fit the PDF after a short delay to ensure the modal is rendered
        setTimeout(() => {
            autoFitPDF();
        }, 300);
    }
}